#include <iostream>
#include <memory>
#include <vector>
using namespace std;

// ======================================================================
class Produit {
public:
  Produit(double une_valeur = 0.0) : valeur(une_valeur) {}

  virtual ~Produit() = 0; // permet de rendre la classe abstraite

  virtual double prix()                    const  { return valeur;    }
  // methode virtuelle, permet l'affichage polymorphique dans les
  // sous-classes de Produit
  virtual void   afficher(ostream& sortie) const  { sortie << prix(); }

private:
  const double valeur;
};

Produit::~Produit() {}

ostream& operator<<(ostream& sortie, Produit const& machin) {
  machin.afficher(sortie);
  return sortie;
}

// ======================================================================
class Accessoire : public Produit {
public:
  Accessoire(string const& un_nom,
             double prix_de_base)
  : Produit(prix_de_base), nom(un_nom)
  {}

  // les destructeur est polymorphique pour que les objets des
  // sous-classes appelent leur destructeurs propres
  virtual ~Accessoire() {}

  virtual void afficher(ostream& sortie)
                             const override {
    sortie << nom << " coutant ";
    Produit::afficher(sortie);
  }

private:
  const string nom;
};

//------------------------------------------------------------
// les autres objets qui héritent de Accessoire ne diffèrent
// que par leurs constructeurs
class Bracelet : public Accessoire {
public:
  Bracelet(string const& un_nom, double prix_de_base)
    : Accessoire("bracelet " + un_nom, prix_de_base)
  {}
  virtual ~Bracelet() {}
};

//------------------------------------------------------------
class Fermoir : public Accessoire {
public:
  Fermoir(string const& un_nom, double prix_de_base)
    : Accessoire("fermoir " + un_nom, prix_de_base)
  {}
  virtual ~Fermoir() {}
};

//------------------------------------------------------------
class Boitier : public Accessoire {
public:
  Boitier(string const& un_nom, double prix_de_base)
    : Accessoire("boitier " + un_nom, prix_de_base)
  {}
  virtual ~Boitier() {}
};

//------------------------------------------------------------
class Vitre : public Accessoire {
public:
  Vitre(string const& un_nom, double prix_de_base)
    : Accessoire("vitre " + un_nom, prix_de_base)
  {}
  virtual ~Vitre() {}
};

// ======================================================================
class Mecanisme : public Produit {};

// ======================================================================
class Montre : public Produit {
public:
  Montre() = default;
  virtual ~Montre() {}

  virtual double prix() const override {
    double prix_final(Produit::prix()); // Au départ, le prix est la valeur de base
    for (auto const& p_acc : accessoires) {
      prix_final += p_acc->prix();
    }
    return prix_final;
  }

  void operator+=(Accessoire* p_accessoire) {
    accessoires.push_back(unique_ptr<Accessoire>(p_accessoire));
  }

  virtual void afficher(ostream& sortie) const override {
    sortie << "Une montre composée de :" << endl;
    for (auto const& p_acc : accessoires) {
      sortie << "  * " << *p_acc << endl; // <<*p_acc affiche un `Produit`
    }
    sortie << "==> Prix total : " << prix() << endl;
  }

private:
  // unique_ptr<Mecanisme> coeur;
  vector<unique_ptr<Accessoire>> accessoires;

  // on empeche la copie et l'affectation à ce stade de la conception
  Montre(const Montre&)     = delete;
  Montre& operator=(Montre) = delete;
};

// ======================================================================
int main() {

  Montre m;

  m += new Bracelet("cuir", 54.0);
  m += new Fermoir("acier", 12.5);
  m += new Boitier("acier", 36.60);
  m += new Vitre("quartz", 44.80);

  cout << "Montre m :" << endl;
  cout << m << endl;

  return 0;
}
