CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente VARCHAR(100) NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela Filha (Detalhe)
CREATE TABLE itens_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedidos(id) ON DELETE CASCADE,
    produto_nome VARCHAR(100) NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario NUMERIC(10, 2) NOT NULL
);

CREATE OR REPLACE FUNCTION fn_recalcula_total_pedido()
RETURNS TRIGGER AS $$
DECLARE
    v_pedido_id INT; --declara variavel
BEGIN

    IF (TG_OP = 'DELETE') THEN --se a tag de operação for = a delete entao
        v_pedido_id := OLD.pedido_id; --valor pedido = ao antigo id do pedido
    ELSE --senao
        v_pedido_id := NEW.pedido_id; --valor pedido = ao novo id do pedido
    END IF;


    UPDATE pedidos
    SET valor_total = COALESCE((               --seta o valor total em ordem q é informada
        SELECT SUM(quantidade * preco_unitario)  --multiplica quantidade e preço unitario
        FROM itens_pedido  --da tabela intens_pedidos
        WHERE pedido_id = v_pedido_id --onde pedidos id = valor pedido id
    ), 0.00)
    WHERE id = v_pedido_id; --onde id = v_pedido_id

    IF (TG_OP = 'DELETE') THEN  --se a tag de operação for = a delete entao
        RETURN OLD; --retorne old
    END IF; --termina o if
    RETURN NEW; --retorna new
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_atualiza_total_pedido
AFTER INSERT OR UPDATE OR DELETE ON itens_pedido --depois de inserir ou atualizar ou deletar itens_pedidos
FOR EACH ROW -- para cada linha
EXECUTE FUNCTION fn_recalcula_total_pedido(); --execute a função