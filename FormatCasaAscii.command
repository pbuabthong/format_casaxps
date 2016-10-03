#!/usr/bin/env python3

import os, ntpath, re, time
from shutil import copyfile
from pathlib import Path

import astropy.io.ascii as ac
from sortcolumn import SortColumn as sc

# from choosecolumn import ChooseColumn

import tkinter as tk
from tkinter import messagebox, filedialog, constants, IntVar, StringVar

class FormatCasaAscii(tk.Frame):

	def __init__(self, root):
		tk.Frame.__init__(self,root)
		center(root)
		self.root = root
		self.grid()
		self.columnconfigure(0, weight=1)
		self.rowconfigure(0, weight=1)
		button_opt = {'padx': 10, 'pady': 10}
		self.openfile_btn = tk.Button(self, text='Open description file', command=self.askopenfile, **button_opt)
		self.openfile_btn.grid(row=1, column=1, columnspan=2, sticky=tk.EW)
		
		# define options for opening a file
		self.file_opt = options = {}
		options['defaultextension'] = '.txt'
		options['filetypes'] = [('all files', '.*'), ('text files', '.txt')]
		options['parent'] = root
		options['title'] = 'Choose the main file'

	def askopenfile(self):
		"""Returns an opened file in read mode"""
		descfilename = tk.filedialog.askopenfilename(**self.file_opt)
		print(descfilename)
		self.load_vamas_ascii(descfilename)
		return descfilename

	def load_vamas_ascii(self, descfilename):
		self.descpath = ntpath.dirname(descfilename)
		print(self.descpath)
		self.openfile_btn.config(state=tk.DISABLED)
		with open(descfilename) as descfile:
			filename_old = ""
			filename_new = ""
			filedict = {}
			c = 1
			for line in descfile:
				line = line.rstrip()
				if (c % 4) == 1:
					filename_old = ntpath.basename(line)
				if (c % 4) == 2:
					find = re.compile(r"^(.*)\/.*")
					m = re.search(find, line)
					filename_new = m.group(1) if not (m is None) else line
					filename_new = re.sub('[^A-Za-z0-9]+', '', filename_new)
					filename_new += ".txt"

				if (c % 4) == 0:
					filedict[filename_old] = filename_new

				c += 1

			print(filedict)
			self.generate_rename_tables(filedict)

	def generate_rename_tables(self, filedict):
		self.entries = {}
		self.labels = {}
		self.tableheight = len(filedict) + 2
		counter = 0
		for key, value in filedict.items():
			self.labels[counter] = tk.Label(self, text=key)
			self.labels[counter].grid(row=counter+2, column=1)

			self.entries[counter] = tk.Entry(self, width=10)
			self.entries[counter].insert(0, value)
			self.entries[counter].grid(row=counter+2, column=2)
			counter += 1
		self.rename_btn = tk.Button(self, text='Create files', command=self.create_newfiles)
		self.rename_btn.grid(row=counter+2, column=1, columnspan=2, sticky="WE")
		self.rename_btn.focus_set()

	def create_newfiles(self):
		for i in range(len(self.labels)):
			fn_old = self.labels[i].cget("text")
			fn_new = self.entries[i].get()

			valid = True

			print(self.descpath + "/" + fn_old + ": %s" % Path(self.descpath + "/" + fn_old).is_file())
			if not Path(self.descpath + "/" + fn_old).is_file():
				self.alertbox("file " + fn_old + " doesn't exist")
				valid = False
				break 
			print(self.descpath + "/" + fn_new + ": %s" % Path(self.descpath + "/" + fn_new).is_file())
			if Path(self.descpath + "/" + fn_new).is_file():
				self.alertbox("file " + fn_new + " already existed")
				valid = False
				break

		if valid:
			print("Creating files")
			newfiledict = {}
			for i in range(len(self.labels)):
				fp_old = self.descpath + "/" + self.labels[i].cget("text")
				fp_new = self.entries[i].get()
				newfiledict[i] = self.descpath + "/" + fp_new
				self.labels[i]['text'] = fp_new + " created"
				self.labels[i].grid(row=i+2, column=1, columnspan=2)
				self.entries[i].grid_forget()
				copyfile(fp_old, self.descpath + "/" + fp_new)

			self.rename_btn.config(text='Format ASCII')
			self.rename_btn.config(command = lambda: self.format_ascii(newfiledict))

	def alertbox(self, msg):
		messagebox.showinfo("Error", msg)

	def format_ascii(self, nfilelist):
		print("Total number of files to process: " + str(len(nfilelist)))
		self.total_files_to_process = len(nfilelist)
		self.files_processed = 0
		self.nfilelist = nfilelist
		self.preparelist(nfilelist)

	def preparelist(self, nfilelist):
		print(nfilelist)
		ccw = tk.Toplevel(self) # choose column window
		createwindow(self.root, ccw, 1, 0)
		ccw.wm_title(ntpath.basename(nfilelist[self.files_processed]))

		self.labels[self.files_processed].config(bg = "khaki")

		descfilename = nfilelist[self.files_processed]
		with open(descfilename) as descfile:
			for _ in range(7):
				next(descfile)
			content = descfile.read()
			data = ac.read(content, data_start=2)
			avail_col = data.colnames

		self.colvar = {}
		button_opt = {'padx': 10, 'pady': 10}
		l = tk.Label(ccw, text="Select columns: ")
		l.pack(side="top", fill="both",**button_opt)
		for i in range(len(avail_col)):
			self.colvar[i] = IntVar()
			c = tk.Checkbutton(ccw, text=avail_col[i], variable=self.colvar[i])
			c.pack(side="top", fill="both",**button_opt)
			default_select = ['B.E.', 'CPS']
			if avail_col[i] in default_select: c.select()

		ok_btn = tk.Button(ccw, text='Ok', command=lambda:self.create_columns(ccw, avail_col, descfilename))
		ok_btn.pack(side="top", fill="both",**button_opt)
		ok_btn.focus_set()
		print("Available columns: ", avail_col)

		return avail_col

	def create_columns(self, toplevel, avail_col, descfilename):
		self.sel_col = []
		for i in range(len(self.colvar)):
			if self.colvar[i].get(): self.sel_col.append(avail_col[i])
		print("Selected columns: ", self.sel_col)

		self.col_selected(self.sel_col, descfilename)
		toplevel.destroy()
		return self.sel_col

	def col_selected(self, col, savefilename):
		print(self.files_processed)
		with open(savefilename) as descfile:
			for _ in range(7):
				next(descfile)
			content = descfile.read()
			data = ac.read(content, data_start=2)

		self.order_columns(col, savefilename, data)

	def order_columns(self, col, savefilename, data):
		scw = tk.Toplevel(self) # sort column window
		createwindow(self.root, scw, 1, 0)
		scw.wm_title(ntpath.basename(savefilename))
		self.scw = scw

		l = tk.Label(scw, text="Please specify columns order: ")
		l.grid(row = 0, column = 0, columnspan = 2, padx=10, pady=10)
		optionList = list(map(str,range(1, len(col)+1)))
		self.order = [None] * len(col)
		w = {}
		col_name = {}
		om_opt = {'padx': 5}
		for i in range(len(col)):
			col_name[i] = tk.Label(scw, text=col[i]+" : ")
			col_name[i].grid(row = i+1, column = 0, sticky=tk.E)

			self.order[i] = StringVar(self)
			self.order[i].set(optionList[i])
			w[i] = tk.OptionMenu(scw, self.order[i], *optionList)
			w[i].grid(row = i+1, column = 1, **om_opt, sticky=tk.W)

		ok_btn = tk.Button(scw, text='Ok', command= lambda:self.sort_columns(col, savefilename, data))
		ok_btn.grid(row = len(col)+2, column = 0, columnspan=2, sticky=tk.NSEW, **om_opt)
		ok_btn.focus_set()
		cancel_btn = tk.Button(scw, text='Cancel', command= lambda:self.destroy())
		cancel_btn.grid(row = len(col)+3, column = 0, columnspan=2, sticky=tk.NSEW, **om_opt)

	def sort_columns(self, col, descfilename, data):
		sorted_col = []
		for i in range(len(col)):
			for j in range(len(col)):
				curr_order = self.order[j].get()
				if i+1 == int(curr_order): sorted_col.append(col[j])

		self.export_columns(sorted_col, descfilename, data)

	def export_columns(self, sorted_col, descfilename, data):
		print(data[sorted_col])
		ac.write(data[sorted_col], descfilename, delimiter="\t")
		self.scw.destroy()
		self.labels[self.files_processed].config(bg = "lightgreen")
		self.files_processed = self.files_processed + 1
		if self.files_processed < self.total_files_to_process:
			self.preparelist(self.nfilelist)
		else:
			self.alertbox("Finished!")
			self.quit()
			self.destroy()

			# open new window for the next process
			FormatCasaAscii(root)
			root.title("FormatCasaAscii")
			root.lift()
			os.system('''/usr/bin/osascript -e 'tell app "Finder" to set frontmost of 		process "Python" to true' ''')
			root.mainloop()

def center(toplevel):
	toplevel.update_idletasks()
	w = toplevel.winfo_screenwidth()
	h = toplevel.winfo_screenheight()
	size = (w/5, h/3)
	x = w/2 - size[0]/2
	y = h/2 - size[1]/2
	toplevel.geometry("%dx%d+%d+%d" % (size + (x, y)))

def createwindow(mainwin, sidewin, sidex, sidey):
	sidewin.update_idletasks()
	w = mainwin.winfo_width()
	h = mainwin.winfo_height()
	x = mainwin.winfo_x()
	y = mainwin.winfo_y()
	size = (w, h)
	side_x = x + sidex * w
	side_y = y + sidey * h
	sidewin.geometry("%dx%d+%d+%d" % (size + (side_x, side_y)))

if __name__=='__main__':
	root = tk.Tk()
	FormatCasaAscii(root)
	root.title("FormatCasaAscii")
	root.lift()
	os.system('''/usr/bin/osascript -e 'tell app "Finder" to set frontmost of process "Python" to true' ''')
	root.mainloop()
