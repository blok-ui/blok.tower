import blogish.data.DataModule;
import blok.tower.core.App;
import blok.tower.module.*;

function main() {
  var app = new App<
    DefaultModule,
    DataModule,
    StaticSiteGenerationModule,
    // ServerSideRenderingModule,
    AssetPathModule<'example/blogish/data', 'dist/www', 'dist/cache'>,
    ApiRouteModule<'blogish.api'>,
    LayoutModule<'blogish.layouts'>
  >();
  app.run();
}
