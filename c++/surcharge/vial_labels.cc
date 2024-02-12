#include <iostream>
#include <string>
#include <cmath>
using namespace std;

class Flacon
{
private:
  string nom;
  double volume;
  double pH;

public:
  /*****************************************************
    Compléter le code à partir d'ici
  *******************************************************/
    Flacon(string nom="Eau", double volume=0.0, double pH=7)
    : nom(nom), volume(volume), pH(pH) {}

    ostream& etiquette(ostream& sortie) const {
        // coeff de plus haut degré
        sortie<<nom<<" : "<<volume<<" ml, pH "<<pH;
        return sortie;
    }

    Flacon& operator+=(Flacon const& f2) {
        nom = nom + " + " + f2.nom;
        double volume_(volume);
        volume += f2.volume;
        pH = -log10((volume_*pow(10, -pH) + f2.volume*pow(10, -f2.pH))/(volume_ + f2.volume));
        return (*this);
        }

};
ostream& operator<<(ostream& sortie, Flacon const& f) {
    return f.etiquette(sortie);
    }
const Flacon operator+(Flacon f1, Flacon const& f2) {
    f1 += f2;
    return f1;
    }
/*******************************************
 * Ne rien modifier après cette ligne.
 *******************************************/

void afficher_melange(Flacon const& f1, Flacon const& f2)
{
  cout << "Si je mélange " << endl;
  cout << "\t\"" << f1 << "\"" << endl;
  cout << "avec" << endl;
  cout << "\t\"" << f2 << "\"" << endl;
  cout << "j'obtiens :" << endl;
  cout << "\t\"" << (f1 + f2) << "\"" << endl;
}

int main()
{
  Flacon flacon1("Eau", 600.0, 7.0);
  Flacon flacon2("Acide chlorhydrique", 500.0, 2.0);
  Flacon flacon3("Acide perchlorique",  800.0, 1.5);

  afficher_melange(flacon1, flacon2);
  afficher_melange(flacon2, flacon3);

  return 0;

}
