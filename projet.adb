with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Command_Line;  use Ada.Command_Line;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Maps; use Ada.Strings.Maps;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Strings.Unbounded.Text_IO;
with Ada.Containers; use Ada.Containers;
with Ada.Containers.Vectors;
with Gene_Matrice;-- package qui permet de manipuler des matrices



procedure Projet is
    nb: Integer;
    package Matrice is new Gene_Matrice(BORNE_MAX1=> nb,BORNE_MAX2 =>nb);
    package Vecteur is new Gene_Matrice(BORNE_MAX1 => 1, BORNE_MAX2 =>nb);
    type poids_des_sites is record
        ID : Integer;
        poids : float;
    end record;

    type T_Liste_poids is array (1..nb) of poids_des_sites;
    type String_List is array (1..1000) of String(1 .. 100);
   
   
    T: Matrice.T_Matrice;
    S : Matrice.T_Matrice;
    G : Matrice.T_Matrice;
    pi_k : Vecteur.T_Matrice;
    alpha : float;
    k : Integer;
    nbr_liens : Vecteur.T_Matrice;
    Fichier : Ada.Text_IO.File_Type;
    Nom_Fichier : String(1..1000);
    nbr_sites : Integer;  
    algo : String(1..1000);
    R : String(1..1000);
    e : Float;
   sites_poids : T_Liste_poids;
   
        --permets d'obtenir la taille de la Matrice pour instancier Gene_Matrice
    function Nb_sites(Fichier : in Ada.Text_IO.File_Type) return Integer is
        nb : Integer;
        Ligne : String (1..1024);
        Derniere : Natural;

    begin
        Ada.Text_IO.Get_Line(Fichier, Ligne, Derniere);
        nb := Integer'Value(Ligne(1..1024));
    return nb;

    end Nb_sites;

   

    -- OPTIONS
    procedure options(alpha : in out float; k: in out Integer; algo : in out String; R: in out String; e : in out Float; Nom_Fichier: in out String) is
        Arret_Exception : exception;
        Arret: Integer := 0;
        arg: String(1..1000);

    begin
        --Définition des options par défaut
        alpha := 0.85;
        k := 150;
        algo := "-P";
        R := "output";
        e := 0.0;


        for i in 1 ..Ada.Command_Line.Argument_Count loop
            if Ada.Command_Line.Argument(i) = "-P" then
                null;
            elsif  Ada.Command_Line.Argument(i) = "-C" then
                algo := "-C";

            elsif  Ada.Command_Line.Argument(i) = "-A" then
                --coversionn de l'argument suivant en float permettant la comparaison
                arg := Ada.Command_Line.Argument(i+1);
                if Integer'Value(arg)'Valid and Integer'Value(arg) <= 1 and Integer'Value(arg) >= 0 then
                    alpha := Float'Value(arg);
                else
                    Put_Line("-A n'est pas un entier entre 0 et 1");
                    Arret := 1;
                end if;

            elsif Ada.Command_Line.Argument(i) = "k" then
                arg := Ada.Command_Line.Argument(i+1);
                if Integer'Value(arg)'Valid then
                    k := Integer'Value(arg);
                else
                    Put_Line("k n'est pas un entier");
                    Arret := 1;
                end if;
                
            elsif Ada.Command_Line.Argument(i) = "-E" then

                if Float'Value(Ada.Command_Line.Argument(i+1))'Valid then 
                    e := Float'Value(Ada.Command_Line.Argument(i+1));
                else
                    Put("E n'est pas un floatant");
                    Arret := 1;
                end if;
            elsif Ada.Command_Line.Argument(i) = "-R" then
                R := Ada.Command_Line.Argument(i+1);

            elsif i = Ada.Command_Line.Argument_Count then
                Nom_Fichier := Ada.Command_Line.Argument(i);
            

            --Si l'option donnée n'est valide pour aucun paramètre
            else
                Arret := 1;
            end if;
        end loop; 

        --Exceptions si une ou plusieurs options ne sont pas conformes
        if Arret = 1 then
            raise Arret_Exception;
        end if;
    exception
        when Arret_Exception =>
            Put_Line("Il y a des erreurs dans les commandes");



    end Options;
-- FIN OPTIONS


function Split(Input : String; Separator : Character) return String_List is
      Parts : String_List;
      Current_Part : String(1..1000);
      j : Integer;
   begin
      j := 1;
      Current_Part:= "";
   for I in Input'Range loop
      if Input(I) /= Separator then
         Current_Part:= Current_Part & Input(I);
      else
         Parts(j) := Current_Part;
         j := j +1;
         Current_Part := "";
      end if;
   end loop;

   -- Ajoutez la dernière partie
   Parts(j) := Current_Part;

   return Parts;
end Split;

  --permets de séparer des chaines de caractères en foction des espaces
  -- ici utilisé pour séparer les valeurs(récupérées en string) du fichier d'entrée pour les utiliser 

function sep_string (Str : String) return String_List is
begin
   return Split(Str, ' ');
end sep_string;



procedure Lire_Fichier(Fichier : in Ada.Text_IO.File_Type; T : out Matrice.T_Matrice; nbr_liens : out Vecteur.T_Matrice) is
    Ligne : String (1..1024);
    Derniere : Natural;
    i : Integer;
    j : Integer;
    i_s: String(1..1);  --et non charactère car on va récupérer un string
    j_s : String(1..1); --idem
    str : String(1..1400);

begin
    --saute la 1ère ligne
    Ada.Text_IO.Get_Line(Fichier, Ligne, Derniere);

    while not Ada.Text_IO.End_Of_File(Fichier) loop
       Ada.Text_IO.Get_Line(Fichier, Ligne, Derniere);
       i_s := sep_string(Ligne)(1);
       j_s := sep_string(Ligne)(2);
        --passage en Int car ils sont en string
       i := Integer'Value(i_s);
       j := Integer'Value(j_s);
       T(i,j) := 1.0;
       T(j,i) := 1.0;
       Nbr_liens(1,i):= Nbr_liens(1,i) + Float(1);
       Nbr_liens(1,j) := Nbr_liens(1,j) + Float(1);
    end loop;
end Lire_Fichier;



function calcul_S (T : in Matrice.T_Matrice; nbr_liens : in Vecteur.T_Matrice; nbr_sites : in Integer ) return Matrice.T_Matrice is
    S : Matrice.T_Matrice;
   begin
        for i in 1..nbr_liens'length loop
            for k in 1..nbr_liens'length loop
                
                if nbr_liens(1,i) /= 0.0 then
                    S(i,k) := T(i,k)/nbr_liens(1,i);
                else
                    S(i,k) := 1.0/Float(nbr_sites);
                end if;
            end loop;
        end loop;
        return S;
    end calcul_S;

     

function calcul_G (S :  Matrice.T_Matrice; alpha :  float; nbr_sites :  integer) return Matrice.T_Matrice is
    G : Matrice.T_Matrice;
begin
    for i in 1..S'length loop 
        for j in 1..S'Length loop
            G(i,j) := alpha*S(i,j) + (1.0 - alpha)/Float(nbr_sites); 
        end loop;
    end loop;
    return G;
end calcul_G;


procedure poids_noeuds(G : in Matrice.T_Matrice; pi_k : out Vecteur.T_Matrice; k : in Integer) is
    pi_0 : Vecteur.T_Matrice;
    pi_kp1 : Vecteur.T_Matrice;
    nbr_sites : Integer := G'Length;

begin

    Vecteur.Initialiser(pi_0);   -- fonction implementée dans le module P_Matrice
    Vecteur.Initialiser(pi_kp1);
    for i in G'Range loop
        Vecteur.Remplacer(pi_0, 1,i, 1.0/Float(nbr_sites));  -- fonction implementée dans le module P_Matrice
    end loop;
     pi_k := pi_0;
    for i in 1..k loop

        for j in 1..nbr_sites loop
            for l in 1..nbr_sites loop
                pi_kp1(1,j) := pi_kp1(1,j) + pi_k(1,l)*G(l,j);
            end loop;

        end loop;
        pi_k := pi_kp1;
    end loop;
end poids_noeuds;


    procedure associer_poids_noeuds (pi_k : in Vecteur.T_Matrice; sites_poids : out T_Liste_poids) is
    begin
        for i in pi_k'Range loop
            sites_poids(i).ID := i;
            sites_poids(i).poids := pi_k(1,i);
        end loop;
    end associer_poids_noeuds;



  
   procedure Fusion(V : in out Vecteur.T_Matrice; Gauche, Milieu, Droite : Integer) is
      Temp : Vecteur.T_Matrice;
      I, J, K : Positive := Gauche;
   begin
      for Index in V'Range loop
         Temp(1,Index) := V(1,Index);
      end loop;

      I := Gauche;
      J := Milieu + 1;
      K := Gauche;

      while I <= Milieu and J <= Droite loop
         if Temp(1,I) <= Temp(1,J) then
            V(1,K) := Temp(1,I);
            I := I + 1;
         else
            V(1,K) := Temp(1,J);
            J := J + 1;
         end if;
         K := K + 1;
      end loop;

      while I <= Milieu loop
         V(1,K) := Temp(1,I);
         I := I + 1;
         K := K + 1;
      end loop;

      while J <= Droite loop
         V(1,K) := Temp(1,J);
         J := J + 1;
         K := K + 1;
      end loop;
   end Fusion;

   
   procedure Tri_Fusion_Recursif(V : in out Vecteur.T_Matrice; Gauche, Droite : Positive) is
      Milieu : Positive;
   begin
      if Gauche < Droite then
         Milieu := (Gauche + Droite) / 2;
         Tri_Fusion_Recursif(V, Gauche, Milieu);
         Tri_Fusion_Recursif(V, Milieu + 1, Droite);
         Fusion(V, Gauche, Milieu, Droite);
      end if;
   end Tri_Fusion_Recursif;

   procedure Tri_Fusion_Externe(V : in out Vecteur.T_Matrice) is
   begin
      if V'Length > 1 then
         Tri_Fusion_Recursif(V, 1, V'Length);
      end if;
      end Tri_Fusion_Externe;
      
      
procedure classements(sites_tries: in T_Liste_poids ; R: in String;  Fichier_pr : out Ada.Text_IO.File_Type; Fichier_pwr : out Ada.Text_IO.File_Type; alpha: in Float; k : in Integer) is
    pr : Ada.Text_IO.File_Type; 
    prw : Ada.Text_IO.File_Type;
    --Rangs : sites_tries'Range; 

begin

    Ada.Text_IO.Create(pr, Ada.Text_IO.Out_File, R & ".pr");
    Ada.Text_IO.Create(prw, Ada.Text_IO.Out_File, R & ".prw");


    Ada.Text_IO.Put_Line(prw, Integer'Image(sites_tries'Length) &  " " & Float'Image(alpha) &  " " & Integer'Image(k));


    for i in reverse sites_tries'Range loop
        Ada.Text_IO.Put_Line(pr, Integer'Image(sites_tries(i).ID));
        Ada.Text_IO.Put_Line(prw, Float'Image(sites_tries(i).poids));
    end loop;
end;
   -- FIN CLASSEMENT
begin
        options(alpha,k,algo,R,e,Nom_Fichier);
        nbr_sites := Nb_sites(Fichier);
         Lire_Fichier(Fichier, T, nbr_liens);
         S := calcul_S (T, nbr_liens, nbr_sites);
         G := calcul_G (S, alpha , nbr_sites);
         poids_noeuds(G,pi_k,k); 
         Tri_Fusion_Externe(pi_k); 
         associer_poids_noeuds(pi_k, sites_poids);

end Projet;
