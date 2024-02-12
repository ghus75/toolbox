#include <iostream>
#include <vector>
#include <memory>

using namespace std;

class Forme {
    public:
        virtual void description() const = 0;

        //virtual Forme* copie() const = 0;
        virtual unique_ptr<Forme> copie() const = 0;

        virtual ~Forme() { cout <<"fin de la forme"<<endl;}
        virtual double aire() const = 0; //rend la classe abstraite
    };

class Cercle : public Forme {
    private:
        double rayon;
    public:
        Cercle(double rayon=0.0)
            : rayon(rayon) { cout<<"constructeur: "; description(); }
        Cercle(const Cercle& autre)
            : rayon(autre.rayon) { cout<<"Copie d'un Cercle"<<endl; }
        ~Cercle() { cout<<"fin du Cercle"<<endl; }

        void description() const override {
            cout<<"ceci est un cercle!"<<" "<<rayon<< endl;
            }

        double aire() const override{ return 3.14*rayon*rayon; }

        // utilise le constructeur de copie
        // appelle le destructeur en sortant de la fonction
        //Forme* copie() const override { return new Cercle(*this); }
        unique_ptr<Forme> copie() const override { return unique_ptr<Forme>(new Cercle(*this));}

    };

class Carre : public Forme {
    private:
        double cote;
    public:
        Carre(double cote=0.0)
            : cote(cote) {cout<<"constructeur: "; description();}
        Carre(const Carre& autre)
            : cote(autre.cote) { cout<<"Copie d'un Carre"<<endl; }
        ~Carre() { cout<<"fin du Carre"<<endl; }

        void description() const override {
            cout<<"ceci est un Carré :"<<cote<<endl;
            }

        double aire() const override {return cote*cote;}
        //Forme* copie() const override { return new Carre(*this); }
        unique_ptr<Forme> copie() const override { return unique_ptr<Forme>(new Carre(*this)); }
    };

class Triangle : public Forme {
    private:
        double base;
        double hauteur;
    public:
        Triangle(double base=0.0, double hauteur=0.0)
            : base(base), hauteur(hauteur) { cout<<"constructeur :"; description(); }
        Triangle(const Triangle& autre)
            : base(autre.base), hauteur(autre.hauteur) { cout<<"Copie d'un Triangle"<<endl; }
        ~Triangle() { cout<<"fin du triangle"<<endl; }

        void description() const override {
            cout<<"ceci est un triangle: "<<base<<" "<<hauteur<<endl;
            }

        double aire() const override { return base*hauteur/2.0; }
        //Forme* copie() const { return new Triangle(*this); }
        unique_ptr<Forme> copie() const override { return unique_ptr<Forme>(new Triangle(*this)); }
    };

class Dessin {
    private:
        //vector<Forme*> formes;
        vector<unique_ptr<Forme>> formes;
    public:
        // allocation dynamique de la memoire (via f.copie())
        void ajouteFigure(const Forme& f) {
            // on fait une copie pour que l'allocation de memoire
            // se fasse dans la classe Dessin
            formes.push_back(f.copie());
            }
         // la liberation de la memoire
         // se fait aussi dans la classe
        ~Dessin() {
            cout<<"fin du dessin"<<endl;
            //for (auto &f: formes) {delete f;} // inutile avec unique_ptr
            }

        void affiche() const {
            for (auto const& f: formes) {
                f->description();
                }
            }
    };

void affichageDesc(Forme& f) {
    f.description();
    cout<<" aire = "<<f.aire()<<endl;
    }
/*
void unCercleDePlus(Dessin& img) {
    cout<<"unCercleDePlus:"<<endl;
    // tmp utilise la meme zone memoire que img
    Dessin tmp(img);
    // impossible de copier une instance Dessin avec unique_ptr
    // => Erreur compilation `result type must be constructible from value type of input range`

    tmp.ajouteFigure(Cercle(100));
    cout << "Affichage de 'img': " << endl;
    tmp.affiche();
    // tmp est détruite (via le destructeur de Dessin) et libère la mémoire pointée
    // mais img pointe toujours sur cette zone memoire => segmentation fault
    }
*/

int main() {

Dessin dessin;
// on passe directemtent une instance, ajouteFigure appelle copie()
// qui retourne un new et appelle le destructeur en sortie d'execution
dessin.ajouteFigure(Triangle(3,4));
dessin.ajouteFigure(Carre(2));
dessin.ajouteFigure(Triangle(6,1));
dessin.ajouteFigure(Cercle(12));

//unCercleDePlus(dessin);

cout << endl << "Affichage du dessin : " << endl;
dessin.affiche();

return 0;
}

