package blogish.api;

import blogish.data.*;
import blogish.data.Menu;
import blok.tower.cache.*;
import blok.tower.routing.JsonRpcRoute;

using Kit;

class SiteApi implements JsonRpcRoute<'/api/site'> {
  final repository:Repository;
  final cache:Cache<Dynamic>;

  public function new(repository, cache) {
    this.repository = repository;
    this.cache = cache;
  }

  public function get():Task<Site> {
    return cache.get('site').next(value -> switch value {
      case Some(site): 
        Task.resolve(site);
      case None: repository.getPages().next(pages -> {
        var site = new Site({
          title: 'Blogish',
          menu: new Menu({
            id: 'main',
            options: [
              new MenuOption({
                label: 'Posts',
                type: InternalLink,
                url: blogish.pages.BlogPostArchivePage.createUrl({ page: 1 })
              })
            ].concat([ for (page in pages) 
              new MenuOption({
                label: page.title,
                type: InternalLink,
                url: blogish.pages.PagePage.createUrl({ slug: page.slug })
              })
            ])
          })
        });
        cache.set('site', site);
        site;
      });
    });
  }
}
