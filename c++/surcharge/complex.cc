#include <iostream>
#include <cmath>
#include <string>

using namespace std;

class Complexe {
	private:
        double re;
        double im;

	public:
        // Les valeurs par défaut du constructeurs permettent de plonger les réels
        // dans le corps des complexes : Complexe(double) est autorisé.
        // Autorise aussi la surcharge `d[op]Complexe`.
        Complexe(double r=0.0, double i=0.0): re(r), im(i) {}
        bool operator==(Complexe const& z2) {
            if ((re == z2.re) and (im == z2.im)) return true;
            else return false;
            }
        ostream& affiche(ostream& sortie) const {
            sortie<<re;
            if (im >= 0) sortie<<" + j*"<<im;
            else sortie<<" - j*"<<-im;
            return sortie;
        }
        // surcharge interne car necessite de modifier l'instance (acces internes)
        Complexe& operator+=(Complexe const& z2) {
            /* Fonctionne aussi avec juste un type de retour void, sans retourner *this.
             En C++, toute expression a pourtant une valeur et il serait donc concevable d’écrire z3=(z1+=z2);
             Le résultat de z1+=z2 , qui sera la valeur de z1 après l’opération d’auto-affectation,
             pourra être stocké dans z3 : il s’agit donc d’une instance de même classe que l’opérande z1,
             avec la même valeur.
             Pour éviter une copie superflue, on peut donc retourner une référence sur z1 :
             au niveau avancé, le type de retour des opérateurs d’auto-affectation est
             une référence sur l’instance courante, de la forme Complexe& .*/

             re += z2.re;
             im += z2.im;
             return (*this);
            }
        /*
        // version surcharge interne de l'operateur +
        const Complexe& operator+(Complexe const& z2) const {
            // return *this+= z2 ne compile pas car += n'est pas const
            // il faut utiliser une copie anonyme the *this
            return Complexe(*this) += z2;
            }
        */
        Complexe& operator-=(Complexe const& z2) {
             re -= z2.re;
             im -= z2.im;
             return (*this);
            }
        Complexe& operator*=(Complexe const& z2) {
             // il faut copier re car modifié par re=...
             // avant d'etre utilisé dans im=...
             const double re_(re);
             re = re_*z2.re - im*z2.im;
             im = re_*z2.im + im*z2.re;
             return (*this);
            }
        Complexe& operator/=(Complexe const& z2) {
             const double re_(re);
             re = (re_*z2.re + im*z2.im)/(re_*z2.re + z2.im*z2.im);
             im = (im*z2.re - re_*z2.im)/(z2.re*z2.re + z2.im*z2.im);
             return (*this);
            }

	};

// Surcharges externes
// à privilégier tant qu'on peut se passer de friend et sans copies inutiles
ostream& operator<<(ostream& sortie, const Complexe& z) {
/* doit retourner un ostream& pour pouvoir enchaîner les opérateurs << */
    return z.affiche(sortie);
    }

const Complexe operator+(Complexe z1, const Complexe& z2) {
/* type de retour const complexe pour éviter des modifications
 du type ++(z1+z2) ou (z1+z2)=f(x) */
    z1 += z2; // utilise surcharge interne
    return z1;
    }
const Complexe operator+(const double d, const Complexe& z2) {
/* pas forcément utile, selon le compilateur */
    return Complexe(d) + z2;
    }
const Complexe operator-(Complexe z1, const Complexe& z2) {
    z1 -= z2;
    return z1;
    }
const Complexe operator-(const double d, const Complexe& z2) {
    return Complexe(d) - z2;
    }
const Complexe operator*(Complexe z1, const Complexe& z2) {
    z1 *= z2;
    return z1;
    }
const Complexe operator/(Complexe z1, const Complexe& z2) {
    z1 /= z2;
    return z1;
    }

int main(){
    Complexe defaut;
    Complexe zero(0.0, 0.0);
    Complexe un (1.0, 0.0);
    Complexe i(0.0, 1.0);
    Complexe j;
/*
    cout << zero << " ==? " << defaut;
    if (zero == defaut) cout << " oui" << endl;
    else cout << " non" << endl;

    cout << zero << " ==? " << i;
    if (zero == i) cout << " oui" << endl;
    else cout << " non" << endl;

    j = un + i;
    cout << un << " + " << i << " = " << j << endl;

    Complexe trois(un);
    trois += un;
    trois += 1.0;
    cout <<trois<<endl;
    cout << un << " + " << un << " + 1.0 = " << trois << endl;

    Complexe deux(trois);
    deux -= un;
    cout << trois << " - " << un << " = " << deux << endl;
    trois = 1.0 + deux;
    cout << "1.0 + " << deux << " = " << trois << endl;
*/
    Complexe z(i*i);
    cout << i << " * " << i << " = " << z << endl;
    cout << z << " / " << i << " = " << z/i << " = ";
    cout << (z/=i) << endl;

    Complexe k(2.0,-3.0);
    z = k;
    z *= 2.0;
    z *= i;
    cout << k << " * 2.0 * " << i << " = " << z << endl;
    z = 2.0 * k * i / 1.0;
    cout << " 2.0 * " << k << " * " << i << " / 1 = " << z << endl;

    return 0;
    }
