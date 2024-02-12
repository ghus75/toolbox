#include <iostream>
#include <string>
using namespace std;

class Timbre
{
private:
  static constexpr unsigned int ANNEE_COURANTE = 2016;

  /*****************************************************
   * Compléter le code à partir d'ici
   *****************************************************/
    protected:
        string nom;
        unsigned int annee;
        string pays;
        double valeur_faciale;

    public:
        Timbre(string nom="timbre", unsigned int annee=1900, string pays="Suisse",
        double valeur_faciale=1.0)
        : nom(nom), annee(annee), pays(pays), valeur_faciale(valeur_faciale) {}

        double vente() const{
            if (ANNEE_COURANTE - annee <= 5) {return valeur_faciale;}
            else {return 2.5*valeur_faciale*age();}
            }
        unsigned int age() const { return ANNEE_COURANTE - annee; }
        ostream& affiche(ostream& sortie) const {
            sortie<<"Timbre ";
            afficher(sortie);
            return sortie;
            }
        ostream& afficher(ostream& sortie) const {
            sortie<<"de nom "<<nom<<" datant de "<<annee<<" (provenance "<<pays;
            sortie<<") ayant pour valeur faciale "<<valeur_faciale<<" francs";
            return sortie;
            }
};
ostream& operator<<(ostream& sortie, Timbre const& t) {
    return t.affiche(sortie);
    }

class Rare : public Timbre {
    private:
        // variables de classe, `constrexpr` obligatoire, sinon erreur:
        // ISO C++ forbids in-class initialization of non-const static member
        static constexpr unsigned int PRIX_BASE_TRES_RARE = 600;
        static constexpr unsigned int PRIX_BASE_RARE = 400;
        static constexpr unsigned int PRIX_BASE_PEU_RARE = 50;
        unsigned int nb;
    public:
        Rare(string nom, unsigned int annee, string pays="Suisse",
        double valeur_faciale=1.0, unsigned int nb=100)
        : Timbre(nom, annee, pays, valeur_faciale), nb(nb) {}

        unsigned int nb_exemplaires() const {return nb;}

        double vente() {
            double prix_base;

            if (nb_exemplaires() < 100) prix_base = PRIX_BASE_TRES_RARE;
            else if ((nb_exemplaires() >= 100) && (nb_exemplaires() < 1000)) prix_base = PRIX_BASE_RARE;
            else prix_base = PRIX_BASE_PEU_RARE;

            return prix_base*(age()/10.0);
            }

        ostream& affiche(ostream& sortie) const {
            sortie<<"Timbre rare ("<<nb<<" ex.) ";
            Timbre::afficher(sortie);
            return sortie;
            }
    };
ostream& operator<<(ostream& sortie, Rare const& t) {
    return t.affiche(sortie);
    }

class Commemoratif : public Timbre {
    public:
        Commemoratif(string nom, unsigned int annee, string pays="Suisse",
        double valeur_faciale=1.0)
        : Timbre(nom, annee, pays, valeur_faciale) {}

        ostream& affiche(ostream& sortie) const {
            sortie<<"Timbre commémoratif ";
            Timbre::afficher(sortie);
            return sortie;
            }
        double vente() const{
            return 2*Timbre::vente();
            }
    };
ostream& operator<<(ostream& sortie, Commemoratif const& t) {
    return t.affiche(sortie);
    }

/*******************************************
 * Ne rien modifier après cette ligne.
 *******************************************/
int main()
{
  /* Ordre des arguments :
  *  nom, année d'émission, pays, valeur faciale, nombre d'exemplaires
  */
  Rare t1( "Guarana-4574", 1960, "Mexique", 0.2, 98 );
  Rare t2( "Yoddle-201"  , 1916, "Suisse" , 0.8,  3 );

  /* Ordre des arguments :
  *  nom, année d'émission, pays, valeur faciale, nombre d'exemplaires
  */
  Commemoratif t3( "700eme-501"  , 2002, "Suisse", 1.5 );
  Timbre       t4( "Setchuan-302", 2004, "Chine" , 0.2 );

  /* Nous n'avons pas encore le polymorphisme :-(
   * (=> pas moyen de faire sans copie ici :-( )  */
  cout << t1 << endl;
  cout << "Prix vente : " << t1.vente() << " francs" << endl;
  cout << t2 << endl;
  cout << "Prix vente : " << t2.vente() << " francs" << endl;
  cout << t3 << endl;
  cout << "Prix vente : " << t3.vente() << " francs" << endl;
  cout << t4 << endl;
  cout << "Prix vente : " << t4.vente() << " francs" << endl;

  return 0;
}
