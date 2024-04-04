package blok.tower.module;

/**
  Customize the source directory static files are read from, the
  Public directory assets will be saved to, and a Private directory
  for things like cached files.

  Note: paths are always relative to the current working directory. To
  change that behavior, you'll need to remap the `kit.file.Adaptor`
  to a different path (or implementation).
**/
@:genericBuild(blok.tower.module.AssetPathModuleBuilder.buildGeneric())
class AssetPathModule<@:const Source, @:const Public, @:const Private> {}
