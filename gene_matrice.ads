generic
   BORNE_MAX1 : Integer;
   BORNE_MAX2 : Integer;


package gene_matrice is
   type T_Matrice is array (1..BORNE_MAX1,1..BORNE_MAX2) of float; 

   procedure Initialiser(Matrice : out T_Matrice);

   procedure remplacer (Matrice : in out T_Matrice; Indice1 : in Integer; Indice2 : in Integer; Valeur : in Float);
   

   end gene_matrice;
