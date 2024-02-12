#include <iostream>
#include <memory>
#include <vector>
using namespace std;

// ======================================================================
class Produit {
public:
  Produit(double une_valeur = 0.0) : valeur(une_valeur) {}

  virtual ~Produit() = 0;

  virtual double prix()                    const  { return valeur;    }
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
class Mecanisme : public Produit {
public:
  Mecanisme(double valeur_de_base, string une_heure = "12:00")
  : Produit(valeur_de_base), heure(une_heure)
  {}

  virtual ~Mecanisme() {}

  // Tous les mécanismes doivent s'afficher comme ceci (cf `final`)
  virtual void afficher(ostream& sortie) const override final {
    sortie << "mécanisme ";
    afficher_type(sortie); // adaptable grace au polymorphisme
    sortie << " (affichage : ";
    afficher_cadran(sortie); // adaptable grace au polymorphisme
    sortie << "), prix : ";
    Produit::afficher(sortie);
  }

protected:  // On veut offrir la version par défaut aux sous-classes

  // Par défaut, on affiche juste l'heure.
  virtual void afficher_cadran(ostream& sortie) const {
    sortie << heure;
  }

private: // ou protected: ici les deux sont envisageables, mais private suffit ici
  string heure;

  // Un mécanisme, ici à ce niveau, reste abstrait (= classe abstraite)
  virtual void afficher_type(ostream& sortie) const = 0;
};

//======================================================================
class MecanismeAnalogique: virtual public Mecanisme {
public:
  MecanismeAnalogique(double valeur_de_base, string une_heure, int une_date)
 : Mecanisme(valeur_de_base, une_heure), date(une_date)
  {}

  // gestion propre de la valeur par défaut de l'heure (super-classe)
  // ce 2e constructeur permet d'appelre le constructeur de la super-classe avec l'heure par défaut
  MecanismeAnalogique(double valeur_de_base, int une_date)
  : Mecanisme(valeur_de_base), date(une_date)
  {}

  virtual ~MecanismeAnalogique() {}

protected:
  virtual void afficher_type(ostream& sortie) const override {
    sortie << "analogique";
  }

  virtual void afficher_cadran(ostream& sortie) const override {
    // On affiche l'heure (façon de base)...
    Mecanisme::afficher_cadran(sortie);
    // ...et en plus la date.
    sortie << ", date " << date;
  }

private:
  int date;
};

//======================================================================
class MecanismeDigital: virtual public Mecanisme {
public:
  MecanismeDigital(double valeur_de_base, string une_heure, string heure_reveil)
  : Mecanisme(valeur_de_base, une_heure), reveil(heure_reveil)
  {}

  // gestion propre de la valeur par défaut de l'heure (super-classe)
  MecanismeDigital(double valeur_de_base, string heure_reveil)
  : Mecanisme(valeur_de_base), reveil(heure_reveil)
  {}

  virtual ~MecanismeDigital() {}

protected:
  virtual void afficher_type(ostream& sortie) const override {
    sortie << "digital";
  }

  virtual void afficher_cadran(ostream& sortie) const override {
    // On affiche l'heure (façon de base)...
    Mecanisme::afficher_cadran(sortie);
    // ...et en plus l'heure de réveil.
    sortie << ", réveil " << reveil;
  }

private:
  string reveil;
};

//======================================================================
class MecanismeDouble: public MecanismeAnalogique, public MecanismeDigital {
public:
  MecanismeDouble(double valeur_de_base, string une_heure, int une_date, string heure_reveil)
  : Mecanisme(valeur_de_base, une_heure)
  , MecanismeAnalogique(valeur_de_base, une_heure, une_date)
  , MecanismeDigital(valeur_de_base, une_heure, heure_reveil)
  {}

  // gestion propre de la valeur par défaut de l'heure (super-classe)
  MecanismeDouble(double valeur_de_base, int une_date, string heure_reveil)
  : Mecanisme(valeur_de_base)
  , MecanismeAnalogique(valeur_de_base, une_date)
  , MecanismeDigital(valeur_de_base, heure_reveil)
  {}

  virtual ~MecanismeDouble() {}

protected:
  virtual void afficher_type(ostream& sortie) const override {
    sortie << "double";
  }

  virtual void afficher_cadran(ostream& sortie) const override {
    // Par exemple...
    sortie << "sur les aiguilles : ";
    MecanismeAnalogique::afficher_cadran(sortie);
    sortie << ", sur l'écran : ";
    MecanismeDigital::afficher_cadran(sortie);
  }
};

// ======================================================================
class Montre : public Produit {
public:
  Montre( Mecanisme* depart)
  : coeur(unique_ptr< Mecanisme>(depart))
  {}
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
      sortie << "  * " << *p_acc << endl;
    }
    sortie << "==> Prix total : " << prix() << endl;
  }

private:
  unique_ptr<Mecanisme> coeur;
  vector<unique_ptr<Accessoire>> accessoires;

  Montre(const Montre&)     = delete;
  Montre& operator=(Montre) = delete;
};

// ======================================================================
int main()
{
  // test de l'affichage des mécanismes
  MecanismeAnalogique v1(312.00, 20141212);
  MecanismeDigital    v2( 32.00, "11:45", "7:00");
  MecanismeDouble     v3(543.00, "8:20", 20140328, "6:30");
  cout << v1 << endl << v2 << endl << v3 << endl;

  // Test des montres
  Montre m(new MecanismeDouble(468.00, "9:15", 20140401, "7:00"));
  m += new Bracelet("cuir", 54.0);
  m += new Fermoir("acier", 12.5);
  m += new Boitier("acier", 36.60);
  m += new Vitre("quartz", 44.80);
  cout << endl << "Montre m :" << endl;
  cout << m << endl;

  return 0;
}
