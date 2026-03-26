CREATE TABLE produto (
id INT AUTO_INCREMENT,
status CHAR(1) NOT NULL DEFAULT 'A',
descricao VARCHAR(50),
estoqueMinimo INT(11),
estoqueMaximo INT(11),
PRIMARY KEY (id)
);

INSERT INTO produto (descricao, estoqueMinimo, estoqueMaximo)
VALUES
('PENDRIVE', 10, 100),
('MOUSE', 10, 100),
('IOGURTE', 5, 50),
('TEQUILA', 5, 40),
('PRESUNTO', 5, 20);

CREATE TABLE estoque (
id INT AUTO_INCREMENT,
idProduto INT,
qtd INT,
vlrUnitario DECIMAL(9,2) NULL DEFAULT 0.00,
PRIMARY KEY (id)
);

CREATE TABLE produtoEntrada (
id INT AUTO_INCREMENT,
idProduto INT,
qtd INT,
vlrUnitario DECIMAL(9,2) NULL DEFAULT 0.00,
entradaData DATE,
PRIMARY KEY (id)
);

CREATE TABLE produtoSaida (
id INT AUTO_INCREMENT,
idProduto INT,
qtd INT,
saidaData DATE,
vlrUnitario DECIMAL(9,2) NULL DEFAULT 0.00,
PRIMARY KEY (id));

DELIMITER $$
CREATE PROCEDURE SP_AtualizaEstoque(
    IN var_idProduto INT,
    IN var_qtdComprada INT,
    IN var_vlrUnitario DECIMAL(9,2))
BEGIN
DECLARE var_contador INT(11);
SELECT COUNT(*)
INTO var_contador
FROM estoque e
WHERE e.idProduto = var_idProduto;
IF var_contador > 0 THEN
    UPDATE estoque e
    SET e.qtd = e.qtd + var_qtdComprada,
        e.vlrUnitario = var_vlrUnitario
    WHERE e.idProduto = var_idProduto;
ELSE
    INSERT INTO estoque (idProduto, qtd, vlrUnitario)
    VALUES(var_idProduto, var_qtdComprada, var_vlrUnitario);
END IF;
END $$
DELIMITER ;


-- Trigger trg_produtoEntrada_AI (INCLUSÃO de compra)
DELIMITER $$
CREATE TRIGGER trg_produtoEntrada_AI AFTER INSERT
ON produtoEntrada
FOR EACH ROW
BEGIN
CALL SP_AtualizaEstoque (NEW.idProduto,
NEW.qtd,
NEW.vlrUnitario);
END $$
DELIMITER ;
-- TRIGGER de inclusão de compra (produtoEntrada)


-- Trigger trg_produtoEntrada_AD (EXCLUSÃO de compra)
DELIMITER $$
CREATE TRIGGER trg_produtoEntrada_AD AFTER DELETE
ON produtoEntrada
FOR EACH ROW
BEGIN
CALL SP_AtualizaEstoque (OLD.idProduto,
OLD.qtd * - 1,
OLD.vlrUnitario);
END $$
DELIMITER ;
-- TRIGGER de exclusão de compra (produtoEntrada)
-- Remove a quantidade excluída do estoque (usa quantidade negativa).

-- Trigger trg_produtoEntrada_AU (ALTERAÇÃO de compra)
DELIMITER $$
CREATE TRIGGER trg_produtoEntrada_AU AFTER UPDATE
ON produtoEntrada
FOR EACH ROW
BEGIN
CALL SP_AtualizaEstoque (NEW.idProduto,
 NEW.qtd - OLD.qtd,
 NEW.vlrUnitario);
END $$
DELIMITER ;
-- TRIGGER de alteração de compra (produtoEntrada)
-- Atualiza o estoque com a diferença de quantidade.

-- Trigger trg_produtoSaida_AI (INCLUSÃO de venda)
DELIMITER $$
CREATE TRIGGER trg_produtoSaida_AI AFTER INSERT
ON produtoSaida
FOR EACH ROW
BEGIN
CALL SP_AtualizaEstoque (NEW.idProduto,
NEW.qtd * - 1,
NEW.vlrUnitario);
END $$
DELIMITER ;
-- TRIGGER de inclusão de venda (produtoSaida)
-- Reduz a quantidade do estoque.

-- Trigger trg_produtoSaida_AD (EXCLUSÃO de venda)
DELIMITER $$
CREATE TRIGGER trg_produtoSaida_AD AFTER DELETE
ON produtoSaida
FOR EACH ROW
BEGIN
CALL SP_AtualizaEstoque (OLD.idProduto,
OLD.qtd,
OLD.vlrUnitario);
END $$
DELIMITER ;
-- TRIGGER de exclusão de venda (produtoSaida)
-- Recoloca no estoque a quantidade do produto excluído da venda.

-- Trigger trg_produtoSaida_AU (ALTERAÇÃO de venda)
DELIMITER $$
CREATE TRIGGER trg_produtoSaida_AU AFTER UPDATE
ON produtoSaida
FOR EACH ROW
BEGIN
CALL SP_AtualizaEstoque (NEW.idProduto,
OLD.qtd - NEW.qtd,
NEW.vlrUnitario);
END $$
DELIMITER ;
-- TRIGGER de alteração de venda (produtoSaida)
-- Ajusta o estoque com base na diferença entre a quantidade antiga e a nova.


