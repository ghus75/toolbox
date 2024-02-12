#include <iostream>
#include <vector>
#include <string>
using namespace std;

/*******************************************
 * Completez le programme a partir d'ici.
 *******************************************/
// Chaines de caractères à utiliser pour les affichages:
/*
été jeté
d'un
n'est
L'oeuvre
bibliothèque
détruit
*/
class Auteur {
	private:
		string nom;
		bool prime;
	public:
		Auteur(string n, bool p=false): nom(n), prime(p) {}
		Auteur(Auteur const&) = delete; // Auteur n'est pas copiable
		/* Fonctions const car ne modifient pas l'instance.
		 * Elles doivent etre en const car elles seront appelées
		 * par un objet const Auteur& dansla classe Oeuvre.
		 * */
		string getNom() const { return nom; }
		bool getPrix() const { return prime; }
	};

class Oeuvre {
	private:
		string titre;
		const Auteur& auteur;
		string langue;
	public:
		Oeuvre(string titre, const Auteur& auteur, string langue)
		: titre(titre), auteur(auteur), langue(langue) {}
		Oeuvre(Oeuvre const&) = delete; // Oeuvre n'est pas copiable

		string getTitre() const { return titre;}
		const Auteur& getAuteur() const { return auteur; }
		string getLangue() const { return langue; }
		void affiche() const {
			cout<<titre<<", "<<auteur.getNom()<<", en "<<langue<<endl;}
		~Oeuvre() {
			cout<<"L'oeuvre \""<<titre<<", "<<auteur.getNom();
			cout<<", en "<<langue;
			cout<<"\" n'est plus disponible."<<endl;
			}
	};

class Exemplaire {
	private:
		Oeuvre& oeuvre;
	public:
		Exemplaire(Oeuvre& oeuvre): oeuvre(oeuvre) {
			cout<<"Nouvel exemplaire de : "<<oeuvre.getTitre()<<", ";
			cout<<oeuvre.getAuteur().getNom()<<", en ";
			cout<<oeuvre.getLangue()<<endl;
			}
		Exemplaire(const Exemplaire& autre): oeuvre(autre.oeuvre) {
			cout<<"Copie d'un exemplaire de : "<<autre.oeuvre.getTitre();
			cout<<", "<<autre.oeuvre.getAuteur().getNom();
			cout<<", en "<<autre.oeuvre.getLangue()<<endl;
			}
		~Exemplaire() {
			cout<<"Un exemplaire de \""<<oeuvre.getTitre()<<", ";
			cout<<oeuvre.getAuteur().getNom()<<", en ";
			cout<<oeuvre.getLangue()<<"\" a été jeté !"<<endl;
			}
		const Oeuvre& getOeuvre() const {return oeuvre;}
		void affiche() const {
			cout<<"Exemplaire de : "<<oeuvre.getTitre()<<", ";
			cout<<oeuvre.getAuteur().getNom()<<", en ";
			cout<<oeuvre.getLangue();
			}
	};

class Bibliotheque {
	private:
		string nom;
		vector<Exemplaire*> Exemplaires;
	public:
		Bibliotheque(const string& nom): nom(nom) {
			cout<<"La bibliothèque "<<nom<<" est ouverte !"<<endl;
			}
		string getNom() const { return nom; }
		void stocker(Oeuvre& oeuvre, int n=1) {
			for (size_t i(0); i<n; ++i) {
                /* avec declaration du pointeur
                Exemplaire* ptr;
                ptr = new Exemplaire(oeuvre);
                Exemplaires.push_back(ptr); */

                // on met directement le new dans le vector qui attend un type Exemplaire*
                Exemplaires.push_back(new Exemplaire(oeuvre));
                }
			}
        void lister_exemplaires(const string& langue = "") const {
            if (langue.size() == 0) {
                for (auto ex: Exemplaires) {
                        ex->affiche();
                        cout<<endl;
                        }
                }
            else {
                for (auto ex: Exemplaires) {
                    if (ex->getOeuvre().getLangue() == langue) {
                        ex->affiche();
                        cout<<endl;
                        }
                    }
                }
            }
        int compter_exemplaires(Oeuvre& oeuvre) const {
            int compteur(0);
            string titre = oeuvre.getTitre();
            for (auto ex: Exemplaires) {
                if (ex->getOeuvre().getTitre() == titre) { ++compteur; }
                }
            return compteur;
            }
        void afficher_auteurs(bool prime=false) const {
            if (prime == false) {
                for (auto ex: Exemplaires) {
                    cout<<ex->getOeuvre().getAuteur().getNom();
                    cout<<endl;
                    }
                }
            else {
                for (auto ex: Exemplaires) {
                    if (ex->getOeuvre().getAuteur().getPrix() == true) {
                        cout<<ex->getOeuvre().getAuteur().getNom();
                        cout<<endl;
                        }
                    }
                }
            }
        ~Bibliotheque() {
            cout<<"La bibliothèque "<<nom<<" ferme ses portes,"<<endl;
            cout<<"et détruit ses exemplaires :"<<endl;
            if (Exemplaires.size() >= 1) {
                for (auto& ex: Exemplaires) {
                    delete (ex);
                    }
                }
            }
	};

/*******************************************
 * Ne rien modifier apres cette ligne.
 *******************************************/

int main()
{
  Auteur a1("Victor Hugo"),
         a2("Alexandre Dumas"),
         a3("Raymond Queneau", true);

  Oeuvre o1("Les Misérables"           , a1, "français" ),
         o2("L'Homme qui rit"          , a1, "français" ),
         o3("Le Comte de Monte-Cristo" , a2, "français" ),
         o4("Zazie dans le métro"      , a3, "français" ),
         o5("The Count of Monte-Cristo", a2, "anglais" );

  Bibliotheque biblio("municipale");
  biblio.stocker(o1, 2);
  biblio.stocker(o2);
  biblio.stocker(o3, 3);
  biblio.stocker(o4);
  biblio.stocker(o5);

  cout << "La bibliothèque " << biblio.getNom()
       << " offre les exemplaires suivants :" << endl;
  biblio.lister_exemplaires();

  const string langue("anglais");
  cout << " Les exemplaires en "<< langue << " sont :" << endl;
  biblio.lister_exemplaires(langue);

  cout << " Les auteurs à succès sont :" << endl;
  biblio.afficher_auteurs(true);

  cout << " Il y a " << biblio.compter_exemplaires(o3) << " exemplaires de "
       << o3.getTitre() << endl;

  return 0;
}
