package blok.tower.asset;

interface OutputItem {
  public final key:OutputKey;
  public function process(output:Output):Task<Nothing>;
}
