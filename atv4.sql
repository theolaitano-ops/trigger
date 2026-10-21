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
	insert into cliente_deletado_log(cliente_id, nome, email)
	VALUES (OLD.id, OLD.nome, OLD.email);
	update clientes set ativo = false where id = old.id;

return null;
end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_soft_delete_cliente
before delete on clientes 
for each row
EXECUTE FUNCTION fn_soft_delete_cliente();