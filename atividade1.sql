create table estoque (
id serial primary key,
nome_item varchar(100) not null,
quantidade int not null default 0
);

create or replace function fn_valida_estoque_minimo() --crio a função q valida o estoque
returns trigger as $$
begin 
	if new_quantidade < 0 then  --falo q se a quantidade for menor q 0, cancela a operação
	raise exception 'Operação cancelada! O item "%" não pode ter estoque negativo (Tentativa: % unidade(s)).',
	new.nome_item, new.quantidade;
end if;
return new;
end;

$$ LANGUAGE plpgsql;

create trigger trg_valida_estoque --crio a trigger de validação de estoque

before insert or update on estoque --falo que antes de inserir ou dar update no estoque, é para executar a função
for each row
execute function fn_valida_estoque_minimo();