-- 005_search_idx.sql
-- Add a tsvector column for items and index for full-text search
ALTER TABLE items ADD COLUMN IF NOT EXISTS tsv tsvector;
UPDATE items SET tsv = to_tsvector(coalesce(title,'') || ' ' || coalesce(description,''));
CREATE INDEX IF NOT EXISTS idx_items_tsv ON items USING GIN(tsv);
-- trigger to update tsv on change
CREATE FUNCTION items_tsv_update() RETURNS trigger AS $$
begin
  new.tsv := to_tsvector(coalesce(new.title,'') || ' ' || coalesce(new.description,''));
  return new;
end
$$ LANGUAGE plpgsql;

CREATE TRIGGER items_tsv_trigger BEFORE INSERT OR UPDATE ON items FOR EACH ROW EXECUTE FUNCTION items_tsv_update();
