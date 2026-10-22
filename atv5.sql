create table reservas(
id serial primary key,
numero_quarto int not null,
data_checkin date not null,
data_checkout date not null,
valor_diaria numeric(10,2) not null,
valor_total numeric(10,2) not null
)

create or replace function fn_processa_reserva()
returns trigger as $$
declare
	dia_estadia int; --declara a variavel
begin
	if new.data_checkout <= new.data_checkin then --se a nova data do check-out for menor ou igual a nova data do check-in entao
		raise exception 'A data do check-out (%) precisa ser posterior a data do check-in (%)!', --interrompa o procedimento 
			new.data_checkout, new.data_checkin;
	end if;

	dia_estadia := new.data_checkout - new.data_checkin; --define o valor de estadia(dias)

	new.valor_total:= dia_estadia * new.valor_diaria; --define o valor de valor total(preço)
	
	return new; --retorne novo
end;

$$ language plpgsql;

create trigger trg_processa_reserva
before insert or update on reservas --antes de inserir ou atualizar reservas 
for each row --para cada linha
execute function fn_processa_reserva() --execute a função