package blogish.api;

import blogish.data.*;
import blok.tower.cache.Cache;
import blok.tower.routing.JsonRpcRoute;

using Kit;
using Lambda;

class PostApi implements JsonRpcRoute<'/api/posts'> {
  final repository:Repository;
  final cache:Cache<Dynamic>;

  public function new(repository, cache) {
    this.repository = repository;
    this.cache = cache;
  }

  public function getPost(slug:String):Task<Post> {
    var cacheId = 'post:$slug';
    return cache.get(cacheId).next(value -> switch value {
      case Some(post): 
        Task.resolve(post);
      case None: repository.getPosts().next(pages -> {
        var data = pages.find(data -> data.slug == slug);
        if (data == null) return new Error(NotFound, 'No post exists for $slug');
        var post = Post.fromJson(data);
        cache.set(cacheId, post);
        post;
      });
    });
  }

  public function paginatePosts(page:Int):Task<Paginated> {
    var cacheId = 'paginated-posts:$page';
    return cache.get(cacheId).next(value -> switch value {
      case Some(posts): 
        Task.resolve(posts);
      case None: repository.getPosts().next(files -> {
        var start = page - 1;
        var end = 10; // @todo: make configurable
        var posts = files.slice(start, start + end);
        var paginated = Paginated.fromJson({
          page: page,
          perPage: 10,
          items: posts
        });
        cache.set(cacheId, paginated);
        return paginated;
      });
    });
  }
}
