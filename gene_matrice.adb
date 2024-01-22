with Ada.Text_IO;            use Ada.Text_IO;


package body gene_matrice is

   procedure Initialiser(Matrice : out T_Matrice) is
   begin
      for i in 1..BORNE_MAX1 loop
         for j in 1..BORNE_MAX2 loop
            Matrice(i,j) := 0.0;
         end loop;
      end loop;
   end Initialiser;

   procedure remplacer (Matrice : in out T_Matrice; Indice1 : in Integer; Indice2 : in Integer; Valeur : in Float) is
   begin
      Matrice(Indice1,Indice2) := Valeur;
   end remplacer;

end gene_matrice;