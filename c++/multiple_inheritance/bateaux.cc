#include <iostream>
#include <cmath>
using namespace std;

enum Pavillon { JollyRogers, CompagnieDuSenegal, CompagnieDOstende };

enum Etat { Intact, Endommage, Coule };

int sq(int x)
{
  return x*x;
}

class Coordonnees
{
public:
  Coordonnees(int un_x, int un_y) : x_(un_x), y_(un_y) {}
  int x() const {
    return x_;
  }
  int y() const {
    return y_;
  }
  void operator+=(Coordonnees const& autre); // à définir plus bas
private:
  int x_;
  int y_;
};

class Navire
{
  /*****************************************************
   * Compléter le code à partir d'ici
   *****************************************************/
    protected:
        Coordonnees position_;
        Pavillon pavillon_;
        Etat etat_;
        static int const rayon_rencontre; // attribut de classe
    public:
        Navire(int x, int y, Pavillon pavillon_, Etat etat_=Intact)
        : position_(x, y), pavillon_(pavillon_), etat_(etat_) {}

        Coordonnees position() const { return position_; }
        void avancer(int de_x, int de_y) {
            if (etat_ != Coule) { position_ += Coordonnees(de_x, de_y); }
            }
        void renflouer() { etat_ = Intact; }
        virtual ostream& afficher(ostream&) const;
        virtual void attaque(Navire&)  = 0;
        virtual void replique(Navire&)  = 0;
        virtual void est_touche() = 0;
        void rencontrer(Navire&);

};
int const Navire::rayon_rencontre(10); // attribut de classe
/**
    Navire
      /\
     /  \
Pirate  Marchand
     \  /
      \/
    Felon
**/
// heritage virtual pour eviter la duplication des attributs
// lors d'héritages multiples
class Pirate : public virtual Navire {
    public:
        Pirate(int x, int y, Pavillon pavillon_): Navire(x, y, pavillon_) {}
        ostream& afficher(ostream&) const;

        void attaque(Navire& autre) override {
            if (etat_ != Coule) {
                cout<<"A l'abordage !"<<endl;
                autre.est_touche();
                }
            }
        void replique(Navire& autre)  override {
            if (etat_ != Coule) {
                cout<<"Non mais, ils nous attaquent ! On riposte !!"<<endl;
                attaque(autre);
                }
            }
        void est_touche() override {
            if (etat_ == Intact) { etat_ = Endommage; }
            else if (etat_ == Endommage) { etat_ = Coule; }
            }
    };

class Marchand : public virtual Navire {
    public:
        Marchand(int x, int y, Pavillon pavillon_): Navire(x, y, pavillon_) {}
        ostream& afficher(ostream&) const;

        void attaque(Navire& autre)  override {
            if (etat_ != Coule) cout<<"On vous aura ! (insultes)"<<endl;
            }
        void replique(Navire& autre)  override {
            if (etat_ == Coule) { cout<<"SOS je coule !"<<endl; }
            else { cout<<"Même pas peur !"<<endl; }
            }
        void est_touche() override { etat_ = Coule; }
    };

class Felon : public Marchand, public Pirate {
    public:
        Felon(int x, int y, Pavillon pavillon_)
        : Navire(x, y, pavillon_), Marchand(x, y, pavillon_), Pirate(x, y, pavillon_) {}
        ostream& afficher(ostream&) const;

        void attaque(Navire& autre)  override { Pirate::attaque(autre); }
        void replique(Navire& autre)  override { Marchand::replique(autre); }
        void est_touche() override { Pirate::est_touche(); }
    };

double distance(Coordonnees const& c1, Coordonnees const& c2) {
    return sqrt(sq(c1.x() - c2.x()) + sq(c1.y() - c2.y()));
    }
double distance(Navire const& N1, Navire const& N2) {
    return distance(N1.position(), N2.position());
    }

void Navire::rencontrer(Navire& autre) {
    if ((etat_ != Coule) && (autre.etat_ != Coule) && (pavillon_ != autre.pavillon_)
        && (distance(*this, autre) < Navire::rayon_rencontre)) {
            attaque(autre);
            autre.replique(*this);
            }

        }

// surcharges
void Coordonnees::operator+=(Coordonnees const& autre) {
    x_ += autre.x_;
    y_ += autre.y_;
    }

ostream& operator<<(ostream& sortie, const Coordonnees& c) {
    sortie<<"("<<c.x()<<", "<<c.y()<<")"<<endl;
    return sortie;
    }
ostream& operator<<(ostream& sortie, const Pavillon& pavillon_) {
    if (pavillon_ == JollyRogers) { sortie<<"pirate"; }
    else if (pavillon_ == CompagnieDuSenegal) { sortie<<"français"; }
    else if (pavillon_ == CompagnieDOstende) { sortie<<"autrichien"; }
    else { sortie<<"pavillon inconnu"; }
    return sortie;
    }
ostream& operator<<(ostream& sortie, const Etat& e) {
    if (e == Intact) { sortie<<"intact"; }
    else if (e == Endommage) { sortie<<"ayant subi des dommages"; }
    else if (e == Coule) { sortie<<"coulé"; }
    else { sortie<<"état inconnu"; }
    return sortie;
    }
ostream& operator<<(ostream& sortie, const Navire& n) {
    return n.afficher(sortie);
    }
ostream& operator<<(ostream& sortie, const Pirate& n) {
    return n.afficher(sortie);
    }
ostream& operator<<(ostream& sortie, const Marchand& m) {
    return m.afficher(sortie);
    }

// fonctions définies à l'extérieur de la classe pour que le compilateur
// ait pris connaissance des surcharge d'opérateurs
ostream& Pirate::afficher(ostream& sortie) const {
    sortie<<"bateau pirate";
    Navire::afficher(sortie);
    }

ostream& Marchand::afficher(ostream& sortie) const {
    sortie<<"navire marchand";
    Navire::afficher(sortie);
    }

ostream& Felon::afficher(ostream& sortie) const {
    sortie<<"navire félon";
    Navire::afficher(sortie);
    }

ostream& Navire::afficher(ostream& sortie) const {
    sortie<<" en ("<<position_.x()<<", "<<position_.y()<<")";
    sortie<<" battant pavillon "<<pavillon_<<", "<<etat_;
    return sortie;
    }

/*******************************************
 * Ne rien modifier après cette ligne.
 *******************************************/

void rencontre(Navire& ship1, Navire& ship2)
{
  cout << "Avant la rencontre :" << endl;
  cout << ship1 << endl;
  cout << ship2 << endl;
  cout << "Distance : " << distance(ship1, ship2) << endl;
  ship1.rencontrer(ship2);
  cout << "Apres la rencontre :" << endl;
  cout << ship1 << endl;
  cout << ship2 << endl;
}

int main()
{
  // Test de la partie 1
  cout << "===== Test de la partie 1 =====" << endl << endl;

  // Un bateau pirate 0,0
  Pirate ship1(0, 0, JollyRogers);
  cout << ship1 << endl;

  // Un bateau marchand en 25,0
  Marchand ship2(25, 0, CompagnieDuSenegal);
  cout << ship2 << endl;

  cout << "Distance : " << distance(ship1, ship2) << endl;

  cout << "Quelques déplacements..." << endl;
  cout << "  en haut à droite :" << endl;
  // Se déplace de 75 unités à droite et 10 en haut
  ship1.avancer(75, 10);
  cout << ship1 << endl;

  cout << "  vers le bas :" << endl;
  ship1.avancer(0, -5);
  cout << ship1 << endl;

  cout << endl << "===== Test de la partie 2 =====" << endl << endl;

  cout << "Bateau pirate et marchand ennemis (trop loins) :" << endl;
  rencontre(ship1, ship2);

  cout << endl << "Bateau pirate et marchand ennemis (proches) :" << endl;
  ship1.avancer(-40, -2);
  ship2.avancer(10, 2);
  rencontre(ship1, ship2);

  cout << endl << "Deux bateaux pirates ennemis intacts (proches) :" << endl;
  Pirate ship3(33, 8, CompagnieDOstende);
  rencontre(ship1, ship3);

  cout << endl << "Bateaux pirates avec dommages, ennemis :" << endl;
  rencontre(ship1, ship3);

  cout << endl << "Bateaux marchands ennemis :" << endl;
  Marchand ship4(21, 7, CompagnieDuSenegal);
  Marchand ship5(27, 2, CompagnieDOstende);
  rencontre(ship4, ship5);

  cout << endl << "Pirate vs Felon :" << endl;
  ship3.renflouer();
  Felon ship6(32, 10, CompagnieDuSenegal);
  rencontre(ship3, ship6);

  cout << endl << "Felon vs Pirate :" << endl;
  rencontre(ship6, ship3);

  return 0;
}
