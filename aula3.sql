
-- 1. Tabela Entidade 1 (Lado N)
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    quantidade_estoque INT NOT NULL DEFAULT 0
);

-- 2. Tabela Entidade 2 (Lado N)
CREATE TABLE vendas (
    id SERIAL PRIMARY KEY,
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cliente_nome VARCHAR(100) NOT NULL
);

-- 3. Tabela Associativa / Junção (Onde a Trigger vai atuar)
CREATE TABLE itens_venda (
    venda_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    
    PRIMARY KEY (venda_id, produto_id),
    CONSTRAINT fk_venda FOREIGN KEY (venda_id) REFERENCES vendas(id) ON DELETE CASCADE,
    CONSTRAINT fk_produto FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE CASCADE
);


CREATE OR REPLACE FUNCTION fn_controle_estoque()
RETURNS TRIGGER AS $$
BEGIN
    -- Se for INSERÇÃO (Nova venda do produto)
    IF (TG_OP = 'INSERT') THEN
        UPDATE produtos 
        SET quantidade_estoque = quantidade_estoque - NEW.quantidade 
        WHERE id = NEW.produto_id;
        
    -- Se for EXCLUSÃO (Produto removido da venda ou venda cancelada)
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE produtos 
        SET quantidade_estoque = quantidade_estoque + OLD.quantidade 
        WHERE id = OLD.produto_id;
        
    -- Se for ATUALIZAÇÃO (Alterou a quantidade do produto já vendido)
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Retorna a quantidade antiga para o estoque e abate a nova quantidade
        IF OLD.produto_id = NEW.produto_id THEN
            UPDATE produtos 
            SET quantidade_estoque = (quantidade_estoque + OLD.quantidade) - NEW.quantidade 
            WHERE id = NEW.produto_id;
        ELSE
            -- Caso bizarro onde o usuário trocou o produto na mesma linha de venda
            UPDATE produtos SET quantidade_estoque = quantidade_estoque + OLD.quantidade WHERE id = OLD.produto_id;
            UPDATE produtos SET quantidade_estoque = quantidade_estoque - NEW.quantidade WHERE id = NEW.produto_id;
        END IF;
    END IF;

    RETURN NULL; -- Triggers AFTER retornam NULL
END;
$$ LANGUAGE plpgsql;

-- STREAMING_CHUNK:Vinculando a Trigger à tabela associativa...
-- =========================================================================
-- CRIAÇÃO DA TRIGGER
-- Ela "escuta" apenas a tabela do meio (itens_venda)
-- =========================================================================
CREATE TRIGGER trg_atualiza_estoque
AFTER INSERT OR UPDATE OR DELETE ON itens_venda
FOR EACH ROW
EXECUTE FUNCTION fn_controle_estoque();