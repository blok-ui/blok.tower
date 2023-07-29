package blok.tower.image;

import sys.io.*;
import sys.FileSystem;
import haxe.io.Bytes;
import blok.tower.cli.Process;

using StringTools;
using haxe.io.Path;

final thumbPrefix = '__tn_';

@:structInit
class ImageInfo {
  public final path:String;
  public var width:Int;
  public var height:Int;
  public var format:ImageFormat;
}

typedef ImageOptions = {
  public final engine:ImageEngine;
  public final width:Int;
  public final height:Int;
  public var ?crop:Bool;
  public var ?focus:{x: Float, y: Float};
}

private final processCache:Map<String, Task<ImageInfo>> = [];

// This is taken from https://github.com/benmerckx/image/blob/master/src/image/Image.hx
function process(input:String, output:String, options:ImageOptions):Task<ImageInfo> {
  switch processCache.get(output) {
    case null:
    case cached: return cached;
  }

  if (options.crop == null) options.crop = true;
  if (options.focus == null) options.focus = {x: .5, y: .5};
  
  if (input.withoutDirectory().startsWith(thumbPrefix)) {
    return new Error(
      LoopDetected,
      'Something went wrong: image generator is processing a temporary file it generated.'
      #if debug
      + ' Bailing here as otherwise this can cause endless loops.'
      + ' Note that this only happens with VIPs, and can be avoided by not including'
      + ' files with the .v extension when listing images.'
      #end
    );
  }

  var ratio = .0;
  var newRatio = .0;
  var cropW = 0;
  var cropH = 0;
  var width = 0;
  var height = 0;
  var sizeRatio = .0;
  var path = new Path(input);
  var tmp = thumbPrefix + path.file + '.v';
  var xPos = 0;
  var yPos = 0;

  var promise = getInfo(input).next(info -> {
    ratio = info.width / info.height;
    newRatio = options.width / options.height;
    
    // Compare ratios
    if (ratio > newRatio) {
      // Original image is wider
      height = options.height;
      width = Math.round(options.height * ratio);
      cropH = info.height;
      cropW = Math.round(info.width / width * options.width);
      sizeRatio = options.height / info.height;
    } else {
      // Equal width or smaller
      height = Math.round(options.width / ratio);
      width = options.width;
      cropW = info.width;
      cropH = Math.round(info.height / height * options.height);
      sizeRatio = options.width / info.width;
    }

    xPos = Math.round((options.focus.x * info.width) - (cropW / 2));
    yPos = Math.round((options.focus.y * info.height) - (cropH / 2));

    if (xPos + cropW > info.width) xPos = info.width - cropW;
    if (yPos + cropH > info.height) yPos = info.height - cropH;
    if (xPos < 0) xPos = 0;
    if (yPos < 0) yPos = 0;

    #if php
    if (options.engine == GD) {
      try {
        var createFrom = 'imagecreatefrom' + info.format;
        var src = php.Syntax.code('{0}({1})', createFrom, input);
        var dst = Gd.imagecreatetruecolor(options.width, options.height);
        var outputPath = new Path(output);
        if (outputPath.ext == 'png') {
          Gd.imagealphablending(dst, false);
          Gd.imagesavealpha(dst, true);
          var transparent = Gd.imagecolorallocatealpha(dst, 255, 255, 255, 127);
          Gd.imagefilledrectangle(dst, 0, 0, options.width, options.height, transparent);
        }
        Gd.imagecopyresampled(dst, src, 0, 0, xPos, yPos, options.width, options.height, cropW, cropH);
        Gd.imagedestroy(src);
        switch outputPath.ext.toLowerCase() {
          case 'gif':
            Gd.imagegif(dst, output);
          case 'jpg' | 'jpeg':
            Gd.imagejpeg(dst, output, 96);
          case 'png':
            Gd.imagepng(dst, output, 9);
          case 'bmp':
            Gd.imagebmp(dst, output);
          default:
            var outFunc = 'image'+outputPath.ext;
            php.Syntax.code("$outFunc($dst, $output)");
        }
        Gd.imagedestroy(dst);
        return info;
      } catch (e: Dynamic) {
        return new Error(InternalError, Std.string(e));
      }
    }
    #end

    xPos = Math.round(xPos * sizeRatio);
    yPos = Math.round(yPos * sizeRatio);

    var cmd = switch options.engine {
      case Vips: 'vipsthumbnail';
      case ImageMagick: 'convert';
      case GraphicsMagick: 'gm';
      default: null;
    }
    
    var args = switch options.engine {
      case Vips if (info.format == Gif || info.format == Bmp):
        return new Error(NotImplemented, 'saving gif/bmp files is unsupported in vips');
      case Vips:
        [input, '-s', '${width}x${height}', '-c', '-o', tmp];
      case ImageMagick:
        [input,
          '-resize', '${width}x${height}',
          '-crop', '${options.width}x${options.height}+${xPos}+$yPos',
          '-strip', '+repage',
        output];
      case GraphicsMagick:
        ['convert', input,
          '-resize', '${width}x${height}',
          '-crop', '${options.width}x${options.height}+${xPos}+$yPos',
          '-strip', '+repage',
        output];
      default: 
        null;
    }

    var process = new Process(cmd, args);
    return process
      .getTask()
      .next(code -> switch code {
        case 0: switch options.engine {
          case Vips:
            new Process('vips', [
              'crop',
              Path.join([path.dir, tmp]),
              output, '$xPos', '$yPos', '${options.width}', '${options.height}'
            ]).getTask();
          default:
            Task.resolve(code);
        }
        case code: 
          new Error(InternalError, 'Failed with error code: $code');
      })
      .next(code -> switch code {
        case 0:
          if (FileSystem.exists(Path.join([path.dir, tmp]))) {
            FileSystem.deleteFile(Path.join([path.dir, tmp]));
          }
          Task.resolve(info);
        case code:
          new Error(InternalError, 'Failed with error code: $code');
      });
  }).map(result -> {
    processCache.remove(output);
    return result;
  });

  processCache.set(output, promise);
  return promise;
}

function getInfo(path: String): Task<ImageInfo> {
  var width = 0;
  var height = 0;
  var format:ImageFormat = null;
  var unsupported = 'Unsupported image format';

  return Task.resolve(File.read(path)).next(function (input: FileInput) {
    switch input.readUInt16() {
      case 0x4952:
        input.seek(6, FileSeek.SeekCur);
        if (input.readString(4) != 'WEBP')
          return new Error(UnsupportedMediaType, unsupported);
        format = ImageFormat.WebP;
        switch input.readString(4) {
          case 'VP8 ':
            input.seek(10, FileSeek.SeekCur);
            width = input.readUInt16();
            height = input.readUInt16();
          case 'VP8L':
            input.seek(5, FileSeek.SeekCur);
            var b0 = input.readByte(), b1 = input.readByte(), b2 = input.readByte(), b3 = input.readByte();
            width = 1 + (((b1 & 0x3F) << 8) | b0);
            height = 1 + (((b3 & 0xF) << 10) | (b2 << 2) | ((b1 & 0xC0) >> 6));
          default:
            return new Error(UnsupportedMediaType, unsupported);
        }
      case endian if (endian == 0x4949 || endian == 0x4d4d):
        input.bigEndian = endian == 0x4d4d;
        if (input.readUInt16() != 42)
          return new Error(UnsupportedMediaType, unsupported);
        format = ImageFormat.Tiff;
        var offset = input.readInt32();
        input.seek(offset, FileSeek.SeekBegin);
        var count = input.readUInt16();
        while (count-- > 0 && (width == 0 || height == 0)) {
          var tag = input.readUInt16(),
            type = input.readUInt16(),
            values = input.readInt32();
          var value = switch type {
            case 3: var t = input.readUInt16(); input.readUInt16(); t;
            default: input.readInt32();
          }
          switch tag {
            case 256: width = value;
            case 257: height = value;
            default:
          }
        }
      case 0x4d42:
        format = ImageFormat.Bmp;
        input.seek(16, FileSeek.SeekCur);
        width = input.readInt32();
        height = input.readInt32();
      case 0x5089:
        format = ImageFormat.Png;
        var tmp = Bytes.alloc(256);
        input.bigEndian = true;
        input.readBytes(tmp, 0, 6);
        var i = 200;
        while (i-- > 0) {
          var dataLen = input.readInt32();
          if (input.readInt32() == ('I'.code << 24) | ('H'.code << 16) | ('D'.code << 8) | 'R'.code ) {
            width = input.readInt32();
            height = input.readInt32();
            break;
          }
          while (dataLen > 0) {
            var k = dataLen > tmp.length ? tmp.length : dataLen;
            input.readBytes(tmp, 0, k);
            dataLen -= k;
          }
          var crc = input.readInt32();
        }
      case 0xD8FF:
        format = ImageFormat.Jpg;
        input.bigEndian = true;
        var i = 200;
        while (i-- > 0) {
          switch input.readUInt16() {
            case 0xFFC2, 0xFFC0:
              var len = input.readUInt16();
              var prec = input.readByte();
              height = input.readUInt16();
              width = input.readUInt16();
              break;
            default:
              input.seek(input.readUInt16() - 2, FileSeek.SeekCur);
          }
        }
      case 0x4947:
        format = ImageFormat.Gif;
        input.readInt32();
        width = input.readUInt16();
        height = input.readUInt16();
      default:
        return new Error(UnsupportedMediaType, unsupported);
    }
    input.close();
    return ({
      path: path,
      width: width,
      height: height,
      format: format
    }:ImageInfo);
  });
}

#if php
@:phpGlobal
extern class Gd {
  public static function imagecreatetruecolor(w:Int, h:Int): Dynamic;
  public static function imagecopyresampled(dst_image:Dynamic, src_image:Dynamic, dst_x:Int, dst_y:Int, src_x:Int, src_y:Int, dst_w:Int, dst_h:Int, src_w:Int, src_h:Int): Bool;
  public static function imagedestroy(_image:Dynamic): Bool;
  public static function imagegif(_image:Dynamic,?_to:Dynamic): Bool;
  public static function imagejpeg(_image:Dynamic,?_to:Dynamic,?quality:Int): Bool;
  public static function imagepng(_image:Dynamic,?_to:Dynamic, ?quality:Int): Bool;
  public static function imagebmp(_image:Dynamic,?_to:Dynamic): Bool;
  public static function imagealphablending(image: Dynamic, blendmode: Bool): Bool;
  public static function imagesavealpha(image: Dynamic, saveFlag: Bool): Bool;
  public static function imagecolorallocatealpha(image: Dynamic, red: Int, green: Int, blue: Int, alpha: Int): Int;
  public static function imagefilledrectangle(image: Dynamic, x1: Int, y1: Int, x2: Int, y2: Int, color: Int): Bool;
}
#end
