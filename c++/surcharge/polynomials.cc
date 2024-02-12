#include <iostream>
#include <vector>
#include <string>

using namespace std;

typedef size_t Degre;

class Polynome {
    private:
        vector<double> coeffs;
    public:
        Polynome(double coef=0, Degre deg=0) : coeffs(deg+1, 0.0) {
            coeffs[deg] = coef; // le coef est affecté au plus haut degré
            } // init=monome de degre deg ; coef^deg
        Degre degre() const { return coeffs.size() - 1; }

        ostream& affiche(ostream& sortie) const {
            // coeff de plus haut degré
            sortie<<coeffs[degre()];
            if (degre() > 0) sortie<<"*X^"<<degre();
            // coeffs suivants
            if (degre() >= 1) {
                for (int i(degre()-1); i>0; --i) {
                    if (coeffs[i] > 0) sortie<<"+"<<coeffs[i]<<"*X^"<<i;
                    if (coeffs[i] < 0) sortie<<coeffs[i]<<"*X^"<<i;
                    }
                // dernier coeff de degre 0
                    if (coeffs[0] > 0) sortie<<"+"<<coeffs[0];
                    if (coeffs[0] < 0) sortie<<coeffs[0];
                }
            return sortie;
        }

        // surcharge interne
        Polynome& operator+=(Polynome const& q) {
            // si deg(q) > deg(this), il faut rajouter des zeros
            while(q.degre() > degre()) coeffs.push_back(0);
            for (Degre i(0); i<=q.degre(); ++i) {
            coeffs[i] += q.coeffs[i];
            }
            return (*this);
            }
    };
// surcharges externes
ostream& operator<<(ostream& sortie, const Polynome& p) {
    return p.affiche(sortie);
    }
const Polynome operator+(Polynome p1, const Polynome& p2) {
    p1 += p2; // utilise surcharge interne
    return p1;
    }

int main()
{
/*    Polynome p(3.0, 0); // ou p(3.0); plongement des réels dans le corps des polynomes
    cout<<p<<endl;

    Polynome p1(4.0, 2);
    cout<<p1<<endl;

    p += p1;
    cout<<p<<endl;
//    cout<<p1*5<<endl;
//    cout<<p*p1<<endl;
*/
    Polynome p0(5.43, 0);
    Polynome p1(623.54,1);
    Polynome p2(23.884,3);
    cout<<p0+p1+p2<<endl;

    return 0;
}
