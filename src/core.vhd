library ieee;
use ieee.std_logic_1164.all;

entity core is
end entity core;

architecture behaviour of core is
begin
    ---Inizialization---
    --ToDO
    ---Istruction Fetch Stage---
    istruction_fetch: entity work.istruction_fetch
        port map(
            --ToDo
        )
    --ToDo
    ---Istruction Decode Stage---
    --ToDO
    ---Execute Stage---
    --ToDo
    ---Memory Stage---
    --ToDO
    ---Wrire back Stage---
    --ToDo
end architecture behaviour;