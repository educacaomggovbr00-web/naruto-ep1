"""Index the original generated ninja-neighbor sprites without modifying PNG bytes."""
from index_citizens import main

if __name__ == '__main__':
    main('shinobi-neighbors.png','shinobi-neighbors.json',[
        ('Guardião',80),('Ninja Médica',78),('Aprendiz',72),('Artesão',78)])
