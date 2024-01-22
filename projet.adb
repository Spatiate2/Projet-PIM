with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Command_Line;  
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Text_IO;
with Ada.Containers; use Ada.Containers;
with Ada.Containers.Vectors;
with gene_matrice;-- package qui permet de manipuler des matrices
with Ada.Strings.Bounded;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;



procedure Projet is

  --  package B_Str is new
  --   Ada.Strings.Bounded.Generic_Bounded_Length
  --   (Max => 30);

    Fichier : Ada.Text_IO.File_Type;
    nbr_sites : Integer;
   
   
    --
    alpha : float;
    k : Integer;
    algo : Unbounded_String;
    R : Unbounded_String;
    e : Float;
    pr : Ada.Text_IO.File_Type; 
    prw : Ada.Text_IO.File_Type;
    N_Fichier : String := "exemple2.net";


        --permets d'obtenir la taille de la Matrice pour instancier Gene_Matrice

--Determine le nombre total de sites, situés à la 1ère ligne du fichier
--Paramètres:
--  N_Fichier : in Chaine de caractères  -- nom du fichier
--  
--Retour:
--  nb : Entier --nombre de sites  
    function Nb_sites(N_Fichier : in String) return Integer is
        nb : Integer;
        Ligne : String (1..1024);
        Derniere : Natural;
        Fichier : Ada.Text_IO.File_Type;

    begin
        Open(Fichier, In_File, N_Fichier);
        Ada.Text_IO.Get_Line(Fichier,Ligne,Derniere);
        Close(Fichier);
        nb := Integer'Value(Ligne(1..1));
    return nb;
    end Nb_sites;

   

-- Gestion des options
--Paramètres:
--  Arguments : in Ada.Command_Line.Argument  --Variable contenant les options de la ligne de commande
--
--Retour:
--  alpha: 
--
--
    procedure options(alpha : in out float; k: in out Integer; algo : in out Unbounded_String; R: in out Unbounded_String; e : in out Float; N_Fichier: in out String) is
        Arret_Exception : exception;
        Arret: Integer := 0;                        --pour savoir si on fait la suite du code
        arg:Unbounded_String;

    begin

                    --afin de gérer les cas où il y a des 
            if Ada.Command_Line.Argument(1) = "-P" then
                null;                               --car par défaut
            elsif  Ada.Command_Line.Argument(1) = "-C" then
                algo := To_Unbounded_String("-C");

            elsif  Ada.Command_Line.Argument(1) = "-A" then
                        --conversion de l'argument suivant en float permettant la comparaison
                arg := To_Unbounded_String(Ada.Command_Line.Argument(2));
                if Float'Value(To_String(arg)) <= 1.0 and Float'Value(To_String(arg)) >= 0.0 then
                    alpha := Float'Value(To_String(arg));
                else
                    Put_Line("-A n'est pas un flottant entre 0 et 1");
                    Arret := 1;
                end if;

            elsif Ada.Command_Line.Argument(1) = "-K" then
                arg := To_Unbounded_String(Ada.Command_Line.Argument(2));
                if Integer'Value(To_String(arg)) > 0 then
                    k := Integer'Value(To_String(arg));
                else
                    Put_Line("k n'est pas valide");
                    Arret := 1;
                end if;

            elsif Ada.Command_Line.Argument(1) = "-E" then
                if Float'Value(Ada.Command_Line.Argument(1)) > 0.0 then 
                    e := Float'Value(Ada.Command_Line.Argument(1));
                else
                    Put("E n'est pas valide");
                    Arret := 1;
                end if;

            elsif Ada.Command_Line.Argument(1) = "-R" then
                R := To_Unbounded_String(Ada.Command_Line.Argument(2));


            elsif 1 = Ada.Command_Line.Argument_Count then
                N_Fichier := Ada.Command_Line.Argument(1);
            --Si l'option donnée n'est valide pour aucun paramètre
                Put_Line("l'option donnée ne concerne aucun paramètre");
                Arret := 1;
            end if;


        for i in 2..Ada.Command_Line.Argument_Count loop
            if Ada.Command_Line.Argument(i) = "-P" then
                null;                               --car par défaut
            elsif  Ada.Command_Line.Argument(i) = "-C" then
                algo := To_Unbounded_String("-C");

            elsif  Ada.Command_Line.Argument(i) = "-A" then
                        --conversion de l'argument suivant en float permettant la comparaison
                arg := To_Unbounded_String(Ada.Command_Line.Argument(i+1));
                if Float'Value(To_String(arg)) <= 1.0 and Float'Value(To_String(arg)) >= 0.0 then
                    alpha := Float'Value(To_String(arg));
                else
                    Put_Line("-A n'est pas un flottant entre 0 et 1");
                    Arret := 1;
                end if;
            elsif  Ada.Command_Line.Argument(i-1) = "-A" and  Float'Value(To_String(To_Unbounded_String(Ada.Command_Line.Argument(i))))   then
                    null;



            elsif Ada.Command_Line.Argument(i) = "-K" then
                arg := To_Unbounded_String(Ada.Command_Line.Argument(i+1));
                if Integer'Value(To_String(arg)) > 0 then
                    k := Integer'Value(To_String(arg));
                else
                    Put_Line("k n'est pas valide");
                    Arret := 1;
                end if;
            elsif Ada.Command_Line.Argument(i-1) = "-K" and Integer'Value(To_String(To_Unbounded_String(Ada.Command_Line.Argument(i)))) then
                null;


            elsif Ada.Command_Line.Argument(i) = "-E" then
                if Float'Value(Ada.Command_Line.Argument(i+1)) > 0.0 then 
                    e := Float'Value(Ada.Command_Line.Argument(i+1));
                else
                    Put("E n'est pas valide");
                    Arret := 1;
                end if;

            elsif Ada.Command_Line.Argument(i-1) = "-E" and Float'Value(Ada.Command_Line.Argument(i)) then
                null;


            elsif Ada.Command_Line.Argument(i) = "-R" then
                R := To_Unbounded_String(Ada.Command_Line.Argument(i+1));
            elsif Ada.Command_Line.Argument(i-1) = "-R" then
                null;


            elsif i = Ada.Command_Line.Argument_Count then
                N_Fichier := Ada.Command_Line.Argument(i);
            
            --Si l'option donnée n'est valide pour aucun paramètre
                Put_Line("l'option donnée ne concerne aucun paramètre");
                Arret := 1;
            end if;
        end loop; 

        --Exceptions si une ou plusieurs options ne sont pas conformes
        if Arret = 1 then
            raise Arret_Exception;
        end if;
    exception
        when Arret_Exception =>
            Put_Line("---------------------------------------------");
            Put_Line("Il y a des erreurs dans les commandes");
            Put_Line("---------------------------------------------");

    end Options;
            -- FIN OPTIONS



    procedure matrice_pleine(nb : in Integer) is
        
   package Matrice is new gene_matrice(BORNE_MAX1=> nb,BORNE_MAX2 =>nb); -- permet de manipuler des Matrices
   package Vecteur is new gene_matrice(BORNE_MAX1 => 1, BORNE_MAX2 =>nb); -- permet de manipuler des vecteurs

    type poids_des_sites is record
        ID : Integer;
        poids : float;
    end record;

    type T_Liste_poids is array (1..nb) of poids_des_sites;
    type String_List is array (1..1000) of String(1..100);
   
    sites_poids : T_Liste_poids;    
    T : Matrice.T_Matrice;
    S : Matrice.T_Matrice;
    G : Matrice.T_Matrice;
    pi_k : Vecteur.T_Matrice;
    nbr_liens : Vecteur.T_Matrice;

        --Afin de séparer les "XXXXX XXXXX" en "XXXXX" "XXXXX" venant du fichier



function Split(Input : String; Separator : Character) return String_List is
      Parts : String_List;
      j : Integer; 
      Current_Part : Unbounded_String;       
   begin
      j := 1;
      Current_Part:= Null_Unbounded_String;
   for I in Input'Range loop
      if Input(I) /= Separator then
         Current_Part:= Current_Part & Input(I);
      else
         Parts(j) := To_String(Current_Part);
         j := j +1;
         Current_Part := Null_Unbounded_String;
      end if;
   end loop;

   -- Ajoutez la dernière partie
   Parts(j) := To_String(Current_Part);

   return Parts;
end Split;
  --permets de séparer des chaines de caractères en foction des espaces
  -- ici utilisé pour séparer les valeurs(récupérées en string) du fichier d'entrée pour les utiliser 


function sep_string (Str : String) return String_List is
begin
   return Split(Str, ' ');
end sep_string;




procedure Lire_Fichier(N_Fichier : in String; T : out Matrice.T_Matrice; nbr_liens : out Vecteur.T_Matrice) is
    Ligne : String (1..1024);
    Derniere : Natural;
    i : Integer;
    j : Integer;
    i_s : String(1..1000);  --et non charactère car on va récupérer un string/ verifier longueur necessaire
    j_s : String(1..1000);  --idem
    Fichier : Ada.Text_IO.File_Type;
begin
      Open(Fichier, In_File,N_Fichier);

    --saute la 1ère ligne
    Ada.Text_IO.Get_Line(Fichier, Ligne, Derniere);
    Vecteur.Initialiser(nbr_liens);

    --parcourir tout le fichier
    while not Ada.Text_IO.End_Of_File(Fichier) loop
       Ada.Text_IO.Get(Fichier, Ligne);
       i_s := sep_string(Ligne)(1);
       j_s := sep_string(Ligne)(2);

        --passage en Int car ils sont en string
       i := Integer'Value(i_s);
       j := Integer'Value(j_s);
       T(i,j) := 1.0;
       Nbr_liens(1,i):= Nbr_liens(1,i) + Float(1);
    end loop;
    Close(Fichier);
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


procedure poids_noeuds(G : in Matrice.T_Matrice; pi_k : out Vecteur.T_Matrice; k : in Integer; e : in float ) is
    pi_0 : Vecteur.T_Matrice;
    pi_kp1 : Vecteur.T_Matrice;
    nbr_sites : Integer := G'Length;
    e_temp : float;
    arret : Integer := 0;                                           --pour la robustesse
begin
    Vecteur.Initialiser(pi_0);                                      -- fonction implementée dans le module P_Matrice
    Vecteur.Initialiser(pi_kp1);
    for i in G'Range loop
        Vecteur.remplacer(pi_0, 1,i, 1.0/Float(nbr_sites));         -- fonction implementée dans le module P_Matrice
    end loop;
    pi_k := pi_0;                                                   --initialization pour le calcul des pi_k

    for i in 1..k loop
        e_temp := 0.0;
        while arret = 0 loop                                         --robustesse sur la différence entre pi_k et pi_kp1
            for j in 1..nbr_sites loop
                for l in 1..nbr_sites loop
                    pi_kp1(1,j) := pi_kp1(1,j) + pi_k(1,l)*G(l,j);   --calcul matriciel
                end loop;
                e_temp := e_temp + (pi_kp1(1,j) - pi_k(1,j))**2;     --mise à jour de la distance avec le vecteur précédent
            if Sqrt(e_temp) > e then                                 --verification de la precision
                arret := 1;
            end if;
            e_temp := 0.0;                                           -- remise de e_tep à 0 pour l'itération suivante
        end loop;
        pi_k := pi_kp1;                                              -- maj de pi_k
        end loop;
    end loop;
end poids_noeuds;


                                    --enregistrement afin de lier poids d'un site et id de ce site
procedure associer_poids_noeuds (pi_k : in Vecteur.T_Matrice; sites_poids : out T_Liste_poids) is
begin
    for i in pi_k'Range loop
        sites_poids(i).ID := i-1;
        sites_poids(i).poids := pi_k(1,i);
    end loop;
end associer_poids_noeuds;


                --tri d'une liste avec fusion
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



procedure classements(sites_tries: in T_Liste_poids ; R: in Unbounded_String; alpha: in Float; k : in Integer; pr : out Ada.Text_IO.File_Type; prw : out Ada.Text_IO.File_Type) is
begin
                --création des fichiers texts
    Ada.Text_IO.Create(pr, Ada.Text_IO.Out_File, To_String(R & ".pr"));
    Ada.Text_IO.Create(prw, Ada.Text_IO.Out_File,  To_String(R & ".prw"));

    Ada.Text_IO.Put_Line(prw, Integer'Image(sites_tries'Length) &  " " & Float'Image(alpha) &  " " & Integer'Image(k));

                --ecrire sur les fichiers respectifs
    for i in reverse sites_tries'Range loop
        Ada.Text_IO.Put_Line(pr, Integer'Image(sites_tries(i).ID));
        Ada.Text_IO.Put_Line(prw, Float'Image(sites_tries(i).poids));
    end loop;

    Close(pr);
    Close(prw);
end classements;
     
begin    
    Lire_Fichier(N_Fichier, T, nbr_liens);
    S := calcul_S (T, nbr_liens, nbr_sites);
    G := calcul_G (S, alpha , nbr_sites);
    poids_noeuds(G,pi_k,k,e); 
    Tri_Fusion_Externe(pi_k); 
    associer_poids_noeuds(pi_k, sites_poids);
    classements(sites_poids, R, alpha, k, pr, prw); 
end matrice_pleine;

--procedure globale projet
begin
    alpha := 0.85;
    k := 150;
    algo := To_Unbounded_String("-P");
    R := To_Unbounded_String("output");
    e := 0.0;
    declare
        Nom_Fichier : Unbounded_String := To_Unbounded_String(N_Fichier);
    begin
        options(alpha,k,algo,R,e,N_Fichier);
    end;
    nbr_sites := Nb_sites(N_Fichier);
    if algo = "-P" then
        matrice_pleine(nbr_sites);
    elsif algo = "-C" then
        null;      --algorithme matrice creuse non fait
    else
        Put_Line("Algorithme non valide");
    end if;
end Projet;
