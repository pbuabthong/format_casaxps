import os
import astropy.io.ascii as ac

from sortcolumn import SortColumn as sc

import tkinter as tk
from tkinter import constants, IntVar

class ChooseColumn(object):

	def __init__(self, toplevel, descfilename):
		self.toplevel = toplevel
		self.descfilename = descfilename

	def create_columns(self):
		self.sel_col = []
		for i in range(len(self.var)):
			if self.var[i].get(): self.sel_col.append(self.avail_col[i])

		print("Selected columns: " + self.sel_col)

		self.toplevel.col_selected()
		return self.sel_col

	def preparelist(self):
		print(self.descfilename)
		with open(self.descfilename) as descfile:
			for _ in range(7):
				next(descfile)
			content = descfile.read()
			data = ac.read(content, data_start=2)
			self.avail_col = data.colnames

		self.var = {}
		button_opt = {'padx': 10, 'pady': 10}
		l = tk.Label(self.toplevel, text="Select columns: ")
		l.pack(side="top", fill="both",**button_opt)
		for i in range(len(self.avail_col)):
			self.var[i] = IntVar()
			c = tk.Checkbutton(self.toplevel, text=self.avail_col[i], variable=self.var[i])
			c.pack(side="top", fill="both",**button_opt)
			c.select()

		tk.Button(self.toplevel, text='Ok', command=self.create_columns).pack(side="top", fill="both",**button_opt)
		print("Available columns: ", self.avail_col)

		return self.avail_col

# def center(toplevel):
# 	toplevel.update_idletasks()
# 	w = toplevel.winfo_screenwidth()
# 	h = toplevel.winfo_screenheight()
# 	size = (w/5, h/3)
# 	#size = tuple(int(_) for _ in toplevel.geometry().split('+')[0].split('x'))
# 	x = w/2 - size[0]/2
# 	y = h/2 - size[1]/2
# 	toplevel.geometry("%dx%d+%d+%d" % (size + (x, y)))

# if __name__ == '__main__':
# 	root = tk.Tk()
# 	ChooseColumn(root).pack()
# 	center(root)
# 	root.title("FormatAsciiTest")
# 	root.lift()
# 	os.system('''/usr/bin/osascript -e 'tell app "Finder" to set frontmost of process "Python" to true' ''')
# 	root.mainloop()