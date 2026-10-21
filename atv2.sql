create table contas(
id serial primary key,
cliente varchar(100) not null,
saldo numeric(10,2) not null default 0.00
);

create table movimentacoes(
id serial primary key,
conta_id int references contas(id),
tipo varchar(1) check (tipo in ('c','d')),
valor numeric(10,2) not null,
data_movimento timestamp default current_timestamp
);

create or replace function fn_atualiza_saldo_conta()
returns trigger as $$ 
begin
	if new.tipo = 'c' then  -- diz que se for credito
		update contas set saldo = saldo + new.valor where id = new.conta_id; --pega o saldo + o novo valor onde o id é igual ao novo conta_id
	elseif new.tipo = 'd' then --diz que se for debito
		update contas set saldo = saldo - new.valor where id = new.conta_id; -- pega o saldo - o novo valor onde é igual ao novo conta_id
	end if; --encerra o if
	return new; --retorna novo saldo
end;
$$ --encerra a function
language plpgsql;

create trigger trg_atualiza_saldo --cria a trigger
	after insert on movimentacoes --diz que depois de inserir em movimentalcoes
	for each row --para uma nova linha
execute function fn_atualiza_saldo_conta(); --execute a função