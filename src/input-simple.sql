create table foo (
    foo_id int primary key
);

create table bar (
    bar_id int primary key,
    foo_id int not null
);

alter table bar
    add constraint fk_bar_foo
    foreign key (foo_id)
    references foo(foo_id);
