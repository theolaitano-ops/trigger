create table clientes(
id serial primary key,
nome varchar(100) not null,
email varchar(100) not null,
ativo boolean default true
)

create table clientes_deletados_log(
id serial primary key,
cliente_id int,
nome varchar(100) not null,
email varchar(100) not null,
data_remocao timestamp default current_timestamp
)

create or replace function fn_soft_delete_cliente()
returns trigger as $$
begin
	insert into cliente_deletado_log(cliente_id, nome, email) --insira os dados dos clientes deletados
	VALUES (OLD.id, OLD.nome, OLD.email); --valores
	update clientes set ativo = false where id = old.id; -- atualize clientes, seta ativo como false, onde id = id antigo

return null; --retorna nulo
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_soft_delete_cliente
before delete on clientes  -- depois de deletar
for each row --para cada linha
EXECUTE FUNCTION fn_soft_delete_cliente(); --execute a função