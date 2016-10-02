import os
# import asciitable
import astropy.io.ascii as ac
#from astropy.io import ascii

import tkinter as tk
from tkinter import messagebox, filedialog, constants, IntVar

class FormatAsciiTest(tk.Frame):

	def __init__(self, root):
		tk.Frame.__init__(self, root)
		self.root = root
		self.preparelist(root, "")

	def create_columns(self):
		for i in range(len(self.var)):
			if not self.var[i].get(): self.avail_col.pop(i-1)

		print(self.avail_col)

	def preparelist(self, toplevel, descfilename):
		descfilename = "/Users/pakpoomb/Documents/Caltech/LewisGroup/XPS/Nb/nb0003.txt"
		with open(descfilename) as descfile:
			for _ in range(7):
				next(descfile)
			content = descfile.read()
			data = ac.read(content, data_start=2)
			self.avail_col = data.colnames

		self.var = {}
		button_opt = {'padx': 10, 'pady': 10}
		for i in range(len(self.avail_col)):
			self.var[i] = IntVar()
			c = tk.Checkbutton(toplevel, text=self.avail_col[i], variable=self.var[i])
			c.pack(side="top", fill="both",**button_opt)
			c.select()

		tk.Button(self, text='Ok', command=self.create_columns).pack(side="top", fill="both",**button_opt)
		print(self.avail_col)

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
	FormatAsciiTest(root).pack()
	center(root)
	root.title("FormatAsciiTest")
	root.lift()
	os.system('''/usr/bin/osascript -e 'tell app "Finder" to set frontmost of process "Python" to true' ''')
	root.mainloop()