#include <iostream>
#include <vector>
#include <sstream>

using namespace std;

/*****************************************************
  * Compléter le code à partir d'ici
 *****************************************************/
class Produit {
    protected:
        string nom;
        string unite;
    public:
        Produit(string nom, string unite="")
            : nom(nom), unite(unite) {}
        virtual ~Produit() {};
        string getNom() const { return nom; }
        string getUnite() const { return unite; }

        virtual string toString() const { return nom; }
        virtual const Produit* adapter(double dummy) const { return this; }
        virtual double quantiteTotale(const string& nomProduit) const {
            return (nom == nomProduit);
            }
    };


class Ingredient {
    private:
        /* la ref constante permet de conserver les infos sur le produit
         par exemple si c'est un ProduitCuisine, sinon l'initialisation se fera
         toujours avec un Produit et sa recette ne sera pas affichée */
        const Produit& produit;
        double quantite;
    public:
        Ingredient(const Produit& produit, double quantite)
            : produit(produit), quantite(quantite) {}
        const Produit& getProduit() const { return produit; }
        double getQuantite() const { return quantite; }

        string descriptionAdaptee() const {
            /* alloc statique de px: pointe au meme endroit que le pointeur retourné par
             produit.adapter(quantite);*/
            const Produit* px(produit.adapter(quantite));

            string s(to_string(quantite) + " " + produit.getUnite() + " de "
                        + px->toString());

            /* - Si l'adresse de px diffère de celle de produit, c'est
             parce que produit.adapter() a renvoyé un objet différent, c'est à dire
             un ProduitCuisine, modifié par la recette: dans ce cas, il faut libérer
             la mémoire allouée par new dans adapter().
               - Si c'est un Produit simple, adapter() ne fait que renvoyer this.
             donc pas de memoire allouée dynamiquement à libérer. */
            if (px != &produit) { delete px; }

            return s;
            }

        double quantiteTotale(const string& nomProduit) const {
            return quantite * (produit.quantiteTotale(nomProduit));

            }
    };

class Recette {
    private:
        vector<Ingredient> ingredients;
        string nom;
        double nbFois_;
    public:
        Recette(string nom, double nbFois_=1.)
            : nom(nom), nbFois_(nbFois_) {}

        void ajouter(const Produit &p, double quantite) {
            ingredients.push_back(Ingredient(p, nbFois_*quantite));
            }

        Recette adapter(double n) const {
            /* retourne une nouvelle recette */
            Recette r(nom, n*nbFois_);
            for (auto ing: ingredients) {
                r.ajouter(ing.getProduit(), ing.getQuantite()/nbFois_);
                // r.ajouter() fait un push_back de n*nbFois_*quantite/nbFois_ pour chaque ingredient
                }
            return r;
            }

        string toString() const {
            string s("  Recette \"" + nom + "\" x ");
            ostringstream nb; // conversion avec sstream pour éviter les zeros derrière la virgule
            nb << nbFois_;
            s += nb.str();
            s += ":\n";
            for (size_t i(0); i<ingredients.size(); ++i) {
                s += ("  " + to_string(i+1) + ". ");
                s += ingredients[i].descriptionAdaptee();
                if (i<ingredients.size() - 1) { s+= "\n"; }
                }
            return s;
            }

        double quantiteTotale(const string& nomProduit) const {
            double quantite(0);
            for (auto ing: ingredients) {
                quantite += ing.quantiteTotale(nomProduit);
                }
            return quantite;
            }
    };

class ProduitCuisine : public Produit {
    private:
        Recette r;
    public:
        ProduitCuisine(string nom, string unite="portion(s)")
            : Produit(nom, unite), r(Recette(nom)) { }

        void ajouterARecette(const Produit& produit, double quantite) {
            r.ajouter(produit, quantite); }

        const ProduitCuisine* adapter(double n) const override {
            // alloc dynamique d'un nouveau ProduitCuisine
            ProduitCuisine* ptr(new ProduitCuisine(*this));
            // dont on modifie la recette:
            ptr->r = r.adapter(n);
            // delete sera appelé dans Ingredient::descriptionAdaptee()
            return ptr;
            }

        string toString() const override {
            // representation du produit et de sa recette
            return nom + "\n" + r.toString();
            }

        double quantiteTotale(const string& nomProduit) const override {
            if (Produit(nom).toString() == nomProduit) { return 1; }
            else { return r.quantiteTotale(nomProduit); }
            }
    };


/*******************************************
 * Ne rien modifier après cette ligne.
 *******************************************/
void afficherQuantiteTotale(const Recette& recette, const Produit& produit)
{
  string nom = produit.getNom();
  cout << "Cette recette contient " << recette.quantiteTotale(nom)
       << " " << produit.getUnite() << " de " << nom << endl;
}

int main()
{
  // quelques produits de base
  Produit oeufs("oeufs");
  Produit farine("farine", "grammes");
  Produit beurre("beurre", "grammes");
  Produit sucreGlace("sucre glace", "grammes");
  Produit chocolatNoir("chocolat noir", "grammes");
  Produit amandesMoulues("amandes moulues", "grammes");
  Produit extraitAmandes("extrait d'amandes", "gouttes");

  ProduitCuisine glacage("glaçage au chocolat");
  // recette pour une portion de glaçage:
  glacage.ajouterARecette(chocolatNoir, 200);
  glacage.ajouterARecette(beurre, 25);
  glacage.ajouterARecette(sucreGlace, 100);
  cout << glacage.toString() << endl;

  ProduitCuisine glacageParfume("glaçage au chocolat parfumé");
  // besoin de 1 portions de glaçage au chocolat et de 2 gouttes
  // d'extrait d'amandes pour 1 portion de glaçage parfumé

  glacageParfume.ajouterARecette(extraitAmandes, 2);
  glacageParfume.ajouterARecette(glacage, 1);
  cout << glacageParfume.toString() << endl;

  Recette recette("tourte glacée au chocolat");
  recette.ajouter(oeufs, 5);
  recette.ajouter(farine, 150);
  recette.ajouter(beurre, 100);
  recette.ajouter(amandesMoulues, 50);
  recette.ajouter(glacageParfume, 2);

  cout << "===  Recette finale  =====" << endl;
  cout << recette.toString() << endl;
  afficherQuantiteTotale(recette, beurre);
  cout << endl;

  // double recette
  Recette doubleRecette = recette.adapter(2);
  cout << "===  Recette finale x 2 ===" << endl;
  cout << doubleRecette.toString() << endl;

  afficherQuantiteTotale(doubleRecette, beurre);
  afficherQuantiteTotale(doubleRecette, oeufs);
  afficherQuantiteTotale(doubleRecette, extraitAmandes);
  afficherQuantiteTotale(doubleRecette, glacage);
  cout << endl;

  cout << "===========================\n" << endl;
  cout << "Vérification que le glaçage n'a pas été modifié :\n";
  cout << glacage.toString() << endl;

  return 0;
}
