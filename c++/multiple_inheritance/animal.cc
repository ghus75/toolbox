#include <iostream>

using namespace std;

class Animal {
    public:
        Animal() {cout<<"Animal:"<<endl;}
        ~Animal() { cout<<"fin de l'animal"<<endl;}
    };

class Vivipare : public virtual Animal {
    protected:
        unsigned int gestation; // en jours
    public:
        Vivipare(unsigned int jours=30)
        : Animal(), gestation(jours) {cout<<"Vivipare"<<endl;}
        void naissance() {
            cout<<"Après "<<gestation<<" jours de gestation, ";
            cout<<"je viens de mettre au monde un nouveau bébé."<<endl;
            }
    };

class Ovipare : public virtual Animal {
    protected:
        unsigned int oeufs;
    public:
        Ovipare(unsigned int nb_oeufs=1)
        : Animal(), oeufs(nb_oeufs) {cout<<"Ovipare"<<endl;}
        void naissance() {
            cout<<"Je viens de pondre environ "<<oeufs<<" oeuf(s)."<<endl;
            }
    };

class Ovovivipare: public Vivipare, public Ovipare {
    private:
        bool rare;
    public:
        //using Ovipare::naissance;
        Ovovivipare(unsigned int jours, unsigned int nb_oeufs, bool rare=false)
        : Vivipare(jours), Ovipare(nb_oeufs), rare(rare) {}
        void naissance() {
            cout<<"Après "<<gestation<<" jours de gestation, ";
            cout<<"je viens de mettre au monde "<<oeufs<<" nouveau(x) bébé(s)."<<endl;}
    };

int main()
{
    Ovovivipare o(30,2,false);
    o.naissance();

    return 0;
}
