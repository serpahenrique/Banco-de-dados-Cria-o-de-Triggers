DROP DATABASE IF EXISTS aula04;
CREATE DATABASE aula04;
USE aula04;
-- Criando a tabela produto
CREATE TABLE produto (
codigo CHAR(3),
descricao VARCHAR(50) NOT NULL,
qtd_estoque INT NOT NULL CHECK (qtd_estoque > 0),
PRIMARY KEY (codigo)
);
-- Inserindo produtos
INSERT INTO produto (codigo, descricao, qtd_estoque) VALUES
('001', 'Feijão', 10),
('002', 'Arroz', 5),
('003', 'Farinha', 15);
-- Consulta
SELECT * FROM produto;

-- Criando a tabela itensVenda
CREATE TABLE itensVenda (
id INT,
venda INT,
produto_codigo CHAR(3) NOT NULL,
qtd_vendida INT NOT NULL,
 CONSTRAINT fk_itensVenda_produto
FOREIGN KEY (produto_codigo) REFERENCES produto(codigo),
 CONSTRAINT pk_itensVenda
PRIMARY KEY (id)
);

-- Criando trigger que será executada após as inclusões
DELIMITER $$
CREATE TRIGGER trg_itensvenda_AI AFTER INSERT
ON itensVenda
FOR EACH ROW
BEGIN
UPDATE produto
SET qtd_estoque = qtd_estoque - NEW.qtd_vendida
WHERE codigo = NEW.produto_codigo;
END$$
DELIMITER ;

-- Criando trigger que será executada após a exclusão de um item de venda
-- A ideia é "devolver" ao estoque a quantidade removida da venda
DELIMITER $$
CREATE TRIGGER trg_itensvenda_AD AFTER DELETE
ON itensVenda
FOR EACH ROW
BEGIN
-- Ao remover o item da venda, devolve a quantidade ao estoque
UPDATE produto
SET qtd_estoque = qtd_estoque + OLD.qtd_vendida
WHERE codigo = OLD.produto_codigo;
END$$
DELIMITER ;

-- Verificando o estoque inicial dos produtos
SELECT * FROM produto;
-- Inserindo registros na tabela itensVenda
-- Isso aciona a trigger AFTER INSERT e reduz o estoque automaticamente
INSERT INTO itensVenda VALUES (1, 1, '003', 2); -- Cliente 1 comprou 2 unidades do produto '003'
INSERT INTO itensVenda VALUES (2, 1, '001', 3); -- Cliente 1 comprou 3 unidades do produto '001'
INSERT INTO itensVenda VALUES (3, 1, '002', 1); -- Cliente 1 comprou 1 unidade do produto '002'
INSERT INTO itensVenda VALUES (4, 2, '002', 1); -- Cliente 2 comprou 1 unidade do produto '002'
INSERT INTO itensVenda VALUES (5, 2, '003', 4); -- Cliente 2 comprou 4 unidades do produto '003'
INSERT INTO itensVenda VALUES (6, 2, '001', 3); -- Cliente 2 comprou 3 unidades do produto '001'
INSERT INTO itensVenda VALUES (7, 3, '001', 1); -- Cliente 3 comprou 1 unidade do produto '001'
INSERT INTO itensVenda VALUES (8, 3, '002', 2); -- Cliente 3 comprou 2 unidades do produto '002'
-- Conferindo o estoque atualizado após as vendas
SELECT * FROM produto;

-- Excluindo vendas
DELETE FROM itensVenda WHERE id = 1;


------------------------------------------------------------------------------------------------------------------------------------------------------------------



