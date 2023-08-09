import blogish.module.*;
import blok.tower.core.App;
import blok.tower.module.*;

function main() {
  var app = new App<
    DefaultModule,
    PreConfiguredTargetModule,
    DataModule,
    AssetModule,
    ApiRouteModule<'blogish.api'>,
    LayoutModule<'blogish.layouts'>
  >();
  app.run();
}
