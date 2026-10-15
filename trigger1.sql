create table produtos(
id serial primary key,
nome varchar(100) not null,
preco numeric(10,2) not null
)

create table historico_precos(
id serial primary key,
produto_id int not null,
preco_antigo numeric (10,2),
preco_novo numeric (10,2),
data_alteracao timestamp default current_timestamp
)

create or replace function fn_log_alteracao_preco()
returns trigger as $$
begin
if old.precoantigo is distinct from new.preco then 
	insert into historico_precos(produto_id, preco_antigo, preco_novo)
	values (new.id, old.preco, new.preco);
end if;
return new;
end;
$$ language plpgsql;


create trigger trg_log_preco
after update on produtos 
for each row
execute function fn_log_alteracao_preco();

INSERT INTO produtos (nome, preco) VALUES ('Notebook Gamer', 4500.00);

SELECT * FROM historico_precos;

CREATE OR REPLACE FUNCTION fn_log_alteracao_preco()
RETURNS TRIGGER AS $$
BEGIN
    -- Verifica se o preço antigo é diferente do preço novo
    IF OLD.preco IS DISTINCT FROM NEW.preco THEN
        INSERT INTO historico_precos (produto_id, preco_antigo, preco_novo)
        VALUES (NEW.id, OLD.preco, NEW.preco);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Criando a Trigger propriamente dita vinculada à tabela 'produtos'
--CREATE TRIGGER trg_log_preco
-- AFTER UPDATE ON produtos
-- FOR EACH ROW
-- EXECUTE FUNCTION fn_log_alteracao_preco();

UPDATE produtos SET preco = 4200.00 WHERE id = 1;


UPDATE produtos SET preco = 7000.00 WHERE id = 1;


SELECT * FROM historico_precos;