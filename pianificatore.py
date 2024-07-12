import argparse


class Product:
    ID = 0
    duration = 0
    expiration = 0
    priority = 0

    def __init__(self, ID, duration, expiration, priority):
        self.ID = ID
        self.duration = duration
        self.expiration = expiration
        self.priority = priority

    def calculatePenalty(self, time):
        if (time>=self.expiration): return 0
        return self.priority*(self.expiration-time)

    def __str__(self):
        return f"{self.ID},{self.duration},{self.expiration},{self.priority}\n"

    def from_string(string):
        parts = string.split(',')
        ID = int(parts[0].strip())
        duration = int(parts[1].strip())
        expiration = int(parts[2].strip())
        priority = int(parts[3].strip())
        product = Product(ID, duration, expiration, priority)
        return product



def load(filename):
    products = []
    with open(filename, 'r', encoding='utf-8') as file:
        for line in file:
            products.append(Product.from_string(line))
    return products


def loadPriorities(method, products):
    queues = {}
    assert (method == "EDF" or method == "HPF")
    if method == 'HPF':
        for product in products:
            if (product.priority in queues):
                queues[product.priority].append(product)
            else:
                queues[product.priority] = [product]
    else:
        for product in products:
            if (product.expiration in queues):
                queues[product.expiration].append(product)
            else:
                queues[product.expiration] = [product]

    return queues


def sortQueues(method, products):
    assert (method == "EDF" or method == "HPF")
    if method == 'EDF':
        for queue in products:

            products[queue] = sorted(products[queue], key=lambda x: x.priority, reverse=True)
        products = dict(sorted(products.items()))
    else:
        for queue in products:

            products[queue] = sorted(products[queue], key=lambda x: x.expiration)
        products = dict(sorted(products.items(), reverse=True))
    return products

def simulate(products):
    penalty=0
    simulated=[]
    time=0
    for idx in products:
        queue=products[idx]
        for item in queue:
            time+=item.duration
            simulated.append(f"{item.ID}:{time}:{item.expiration}:{item.priority}")
            penalty+=item.calculatePenalty(time)
    return penalty, simulated, time

if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description='Simulate the asm planner')
    parser.add_argument('filename', type=str,
                        help='name of the file with the products')

    args = parser.parse_args()
    alg = int(input("quale algoritmo si vuole usare?:"))
    method = ""
    assert (alg == 1 or alg == 2)
    if alg == 1:
        method = "EDF"
    if alg == 2:
        method = "HPF"
    products = load(args.filename)
    products = loadPriorities(method,products)
    products = sortQueues(method,products)
    penalty, simulated, time=simulate(products)
    for i in simulated:
        print(i)
    print(f"Conclusione: {time}")
    print(f"Penalty: {penalty}")
