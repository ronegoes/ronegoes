BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS contas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT,
  valor REAL,
  vencimento TEXT,
  paga INTEGER
);
INSERT INTO "contas" ("id","nome","valor","vencimento","paga") VALUES (1,'Internet',99.9,'2025-06-05',0),
 (2,'Luz',120.0,'2025-06-10',0),
 (3,'Água',75.5,'2025-06-12',1),
 (4,'Aluguel',800.0,'2025-06-01',0);
 (4,'farmacia',800.0,'2025-06-01',1);
COMMIT;
