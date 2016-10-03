import os
# import asciitable
import astropy.io.ascii as ac
#from astropy.io import ascii

import tkinter as tk
from tkinter import messagebox, filedialog, constants, IntVar, StringVar

class FormatAsciiTest(tk.Frame):

	def __init__(self, root):
		tk.Frame.__init__(self, root)
		self.root = root
		self.grid()
		col = ['K.E.', 'B.E.', 'CPS']
		descfilename = "/Users/pakpoomb/Documents/Caltech/LewisGroup/XPS/Nb/nb0003.txt"
		with open(descfilename) as descfile:
			for _ in range(7):
				next(descfile)
			content = descfile.read()
			data = ac.read(content, data_start=2)

		savefilename = "/Users/pakpoomb/Documents/Caltech/LewisGroup/XPS/Nb/NN.txt"
		self.order_columns(col, savefilename, data)

	def order_columns(self, col, descfilename, data):
		l = tk.Label(self, text="Please specify columns order: ")
		l.grid(row = 0, column = 0, columnspan = 2, padx=10, pady=10)
		# l.pack(side="top", fill="both", expand=True)
		optionList = list(map(str,range(1, len(col)+1)))
		# print(optionList)
		self.order = [None] * len(col)
		w = {}
		col_name = {}
		om_opt = {'padx': 5}
		for i in range(len(col)):
			col_name[i] = tk.Label(self, text=col[i]+" : ")
			col_name[i].grid(row = i+1, column = 0, sticky=tk.E)

			self.order[i] = StringVar(self)
			self.order[i].set(optionList[i])
			w[i] = tk.OptionMenu(self, self.order[i], *optionList)
			w[i].grid(row = i+1, column = 1, **om_opt, sticky=tk.W)

		ok_btn = tk.Button(self, text='Ok', command= lambda:self.sort_columns(col, descfilename, data))
		ok_btn.grid(row = len(col)+2, column = 0, columnspan=2, sticky=tk.NSEW, **om_opt)
		cancel_btn = tk.Button(self, text='Cancel', command= lambda:self.destroy())
		cancel_btn.grid(row = len(col)+3, column = 0, columnspan=2, sticky=tk.NSEW, **om_opt)

	def sort_columns(self, col, descfilename, data):
		sorted_col = []
		for i in range(len(col)):
			for j in range(len(col)):
				curr_order = self.order[j].get()
				# curr_order = int(curr_order)
				# print(i+1, type(curr_order))
				if i+1 == int(curr_order): sorted_col.append(col[j])

		# print(sorted_col)
		self.export_columns(sorted_col, descfilename, data)

	def export_columns(self, sorted_col, descfilename, data):
		print(data[sorted_col])
		ac.write(data[sorted_col], descfilename, delimiter="\t")

def center(toplevel):
	toplevel.update_idletasks()
	w = toplevel.winfo_screenwidth()
	h = toplevel.winfo_screenheight()
	size = (w/5, h/3)
	#size = tuple(int(_) for _ in toplevel.geometry().split('+')[0].split('x'))
	x = w/2 - size[0]/2
	y = h/2 - size[1]/2
	toplevel.geometry("%dx%d+%d+%d" % (size + (x, y)))

if __name__ == '__main__':
	root = tk.Tk()
	FormatAsciiTest(root)
	center(root)
	root.title("FormatAsciiTest")
	root.lift()
	os.system('''/usr/bin/osascript -e 'tell app "Finder" to set frontmost of process "Python" to true' ''')
	root.mainloop()