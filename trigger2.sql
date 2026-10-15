create table clientes(
id serial primary key,
nome varchar(100) not null,
total_compras numeric(10,2) default 0.00
);

create table pedidos(
id serial primary key,
cliente_id int not null,
valor_total numeric(10,2) not null,
data_pedido timestamp default current_timestamp,
constraint fk_clientes foreign key (cliente_id) references clientes(id) on delete cascade
);

create function fn_atualiza_total_cliente()
returns trigger as $$
declare--diz que oq ta em baixo é uma variavel
	v_cliente_id int;
begin--abre uma unica sessão 
	if (tg_op = 'delete') then
	v_cliente_id := old.cliente_id; --passa o valor de old.cliente_id para v_cliente_id
	-- := é tipo == do js

	else
	v_cliente_id := new.cliente_id; -- caso contrario v_cliente_id vai ter o valor do new.cliente_id
end if;

--atualizar valor

update clientes
set total_compras = coalesce((  --coalesce atribui valor a um espaço "vazio(null)"
	select sum(valor_total)
	from pedidos		--caso tenha calor null passe o valor 0 a eles
	where cliente_id = v_cliente_id
	), 0.00) 
where id = v_cliente_id;  

--caso o cliente queira trocar algo

if (tg_op = 'update' and old.cliente_id is distinct from new.cliente_id) then  --diz q se a tag operacional for igual a update e old cliente id  diferente de new cliente id
	update clientes   
	set total_compras = coalesce((
	select sum (valor_total) --soma o valor total
	from pedidos --na tabela pedidos
	where cliente_id = old.cliente_id --onde o 
	), 0.00);
	where id = old.cliente_id

end if;

return null; --para o trigger no casode after eu n preciso retornar nenhum registro(null)
end;
$$ language plpgsql;

create trigger tgr_atualiza_total_pedidos --nome do trigger
after insert or update or delete on pedidos -- depois inseira ou atualize ou delete pedidos
for each row --para cada linha 
execute function fn_atualiza_total_cliente(); --execute a função

insert into clientes (nome) values ('lucas pavanato'), ('cleiton souza'); --insere os dados na tabela clientes

select * from  clientes --mostra a tabela clientes
 
insert into pedidos (cliente_id, valor_total)  --insere o id do cliente 1 e o valor do pedido
values
(1, 150.00);

insert into pedidos (cliente_id, valor_total)  --insere o id do cliente 1 e o valor do pedido + o valor antigo
values
(1, 50.00);

insert into pedidos (cliente_id, valor_total)  --insere o id do cliente 2 e o valor do pedido
values
(2, 300.00);

select * from clientes --mostra a tabela clinetes (agora com os dados)

update pedidos set valor_total = 100.00 where id = 2 --atualiza o valor de compra do pavanato para 250

select * from clientes where id =1

delete from pedidos where id=1

SELECT * FROM clientes WHERE id = 1;


