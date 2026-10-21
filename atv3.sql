create table funcionarios(
id serial primary key,
nome varchar(100) not null,
cargo varchar(50) not null,
salario numeric(10,2)not null
)

create table historico_carrera(
id serial primary key,
funcionario_id int not null,
cargo_antigo varchar(50),
cargo_novo varchar(50),
salario_antigo varchar(50),
salario_novo varchar(50),
data_alteracao timestamp default current_timestamp
);

create or replace function fn_log_alteracao_carrera()
	returns trigger as $$
	begin
		if old.cargo is distinct from new.cargo or old.salario is distinct from new.salario then
		insert into historico_carrera (funcionario_id, cargo_antigo, cargo_novo, salario_antigo, salario_novo)
		VALUES (OLD.id, OLD.cargo, NEW.cargo, OLD.salario, NEW.salario);
	end if;
	return new;
end;
$$
language plpgsql;

create trigger trg_log_carrera
after update on funcionarios 
for each row
execute function fn_log_alteracao_carrera();