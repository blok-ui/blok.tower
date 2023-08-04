import blogish.data.DataModule;
import blok.tower.core.App;
import blok.tower.module.*;

function main() {
  var app = new App<
    DefaultModule,
    PreConfiguredTargetModule,
    DataModule,
    ApiRouteModule<'blogish.api'>,
    LayoutModule<'blogish.layouts'>
  >();
  app.run();
}
