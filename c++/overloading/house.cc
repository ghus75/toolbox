#include <iostream>
#include <string>
#include <vector>
using namespace std;

// Pour simplifier
typedef string Forme   ;
typedef string Couleur ;

class Brique
{
private:
  Forme   forme   ;
  Couleur couleur ;

public:
  /*****************************************************
    Compléter le code à partir d'ici
  *******************************************************/
  Brique(Forme forme=" pleine ", Couleur couleur="blanc")
  : forme(forme), couleur(couleur) {}
  ostream& afficher(ostream& sortie) const {
    if (couleur.size() > 0) sortie<<"("<<forme<<", "<<couleur<<")";
    else sortie<<forme;
    return sortie;
    }

};
ostream& operator<<(ostream& sortie, const Brique& b) {
    return b.afficher(sortie);
    }

class Construction
{
  friend class Grader;
  private:
    //i=hauteur, j=profondeur, k=largeur
    vector<vector<vector<Brique>>> contenu;
  public:
    Construction(const Brique& b) : contenu({{{b}}}) {}

    ostream& afficher(ostream& sortie) const {
        /* Affichage des couches enpartant de la plus haute */
        // taille de contenu = nombre de couches
        for(int i(contenu.size() - 1); i>=0; --i){
            sortie<<"Couche "<<i<<" :"<<endl;
            // taille de contenu[i] = profondeur de la couche
            for (size_t j(0); j<contenu[i].size(); ++j) {
                //pour chaque rangée de briques à la profondeur j de la couche i
                for (size_t k(0); k<contenu[i][j].size(); ++k){
                    sortie<<contenu[i][j][k]<<" "; // utilise << surchargé pour Brique
                    }
                sortie<<endl; //retour à la ligne après chaque rangée de briques
                }
            //sortie<<endl; //retour à la ligne après chaque couche
            }
        return sortie;
        }

    Construction& operator^=(Construction const& c) {
        // on rajoute les couches de c une par une au-dessus de `contenu`
        for(auto couche : c.contenu) { contenu.push_back(couche); }
        return *this;
        }
    Construction& operator-=(Construction const& c) {
        // on rajoute les couches de c une par une derrière celles de `contenu`
        if (c.contenu.size() >= contenu.size()) {
            for (size_t i(0); i < contenu.size(); ++i) {
                // profondeur de la couche c[i] de la Construction c
                size_t j_max = c.contenu[i].size() -1;
                for(size_t j(0); j<= j_max; ++j) {
                    contenu[i].push_back({c.contenu[i][j]});
                    }
                }

            }
        return *this;
        }
    Construction& operator+=(Construction const& c) {
        /* - si la hauteur de c (élément ajouté à droite) est >= celle de
        `contenu` alors on n’ajoute que la partie de même hauteur que `contenu`,
         le reste de c étant ignoré.
           - si la profondeur de c est >= celle de `contenu`, alors on
        n’ajoute que la partie de même profondeur que `contenu`,
        le reste de c étant ignoré. */
        // hauteur de c
        size_t hauteur(c.contenu.size());
        // profondeur de c, prise à la couche 0
        size_t profondeur(c.contenu[0].size());
        // profondeur de `contenu`, prise à la couche 0
        size_t profondeur_this(contenu[0].size());

        if ((profondeur >= profondeur_this) && (hauteur >= contenu.size())) {
            // on rajoute les couches de c une par une à droite de celles de `contenu`
            // on n’ajoute que la partie de même hauteur que `contenu`
            size_t i_max(contenu.size() - 1); // initialiser les max séparement car push_back change la taille!
            for (size_t i(0); i <= i_max; ++i) {
                // on n’ajoute que la partie de même profondeur que `contenu`
                for(size_t j(0); j< profondeur_this; ++j) {
                    size_t k_max = c.contenu[i][j].size() -1;
                    for (size_t k(0); k <= k_max; ++k) {
                        contenu[i][j].push_back({c.contenu[i][j][k]});
                        }
                    }
                }
            }
        // sinon pas de modifications
        return *this;
        }
};
ostream& operator<<(ostream& sortie, Construction const& c) {
    return c.afficher(sortie);
    }
const Construction operator^(Construction a, Construction const& b) {
    a^=b;
    return a;
    }
const Construction operator-(Construction a, Construction const& b) {
    a-=b;
    return a;
    }
const Construction operator+(Construction a, Construction const& b) {
    a+=b;
    return a;
    }
const Construction operator*(unsigned int n, Construction const& a) {
    Construction n_fois_a(a);
    for(size_t i(0); i<n-1; ++i) { n_fois_a += a; }
     return n_fois_a;
    }
const Construction operator/(unsigned int n, Construction const& a) {
    Construction a_sur_a(a);
    for(size_t i(0); i<n-1; ++i) { a_sur_a ^= a;}
    return a_sur_a;
    }
const Construction operator%(unsigned int n, Construction const& a) {
    Construction a_derriere_a(a);
    for(size_t i(0); i<n-1; ++i) { a_derriere_a -= a;}
    return a_derriere_a;
    }

/*******************************************
 * Ne rien modifier après cette ligne.
 *******************************************/

int main()
{
  // Modèles de briques
  Brique toitD("obliqueD", "rouge");
  Brique toitG("obliqueG", "rouge");
  Brique toitM(" pleine ", "rouge");
  Brique mur  (" pleine ", "blanc");
  Brique vide ("                 ", "");

  unsigned int largeur(4);
  unsigned int profondeur(3);
  unsigned int hauteur(3); // sans le toit

  // on construit les murs
  Construction maison( hauteur / ( profondeur % (largeur * mur) ) );

  // on construit le toit
  Construction toit(profondeur % ( toitG + 2*toitM + toitD ));
  toit ^= profondeur % (vide + toitG + toitD);

  // on pose le toit sur les murs
  maison ^= toit;

  // on admire notre construction
  cout << maison << endl;

  return 0;
}
