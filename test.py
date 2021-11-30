import progressbar


bar = progressbar.ProgressBar(maxval=10000)
bar.start()
lista = []
for i in range(10000):
    lista.append(i)
    bar.update(i)
bar.finish()
