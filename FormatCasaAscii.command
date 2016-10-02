#!/usr/bin/env python3

import os, ntpath, re, time
from shutil import copyfile
from pathlib import Path
import tkinter as tk
from tkinter import messagebox, filedialog, constants

class FormatCasaAscii(tk.Frame):

	def askopenfile(self):
		"""Returns an opened file in read mode"""
		return tk.filedialog.askopenfile(mode='r', **self.file_opt)

	def alertbox(self, msg):
		messagebox.showinfo("Error", msg)

	def format_ascii(self):
		self.alertbox("format!")

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
				newfiledict[i] = fp_new
				self.labels[i]['text'] = fp_new + " created"
				self.labels[i].grid(row=i+2, column=1, columnspan=2)
				self.entries[i].grid_forget()
				# copyfile(fp_old, self.descpath + "/" + fp_new)

			self.rename_btn.config(text='Format ASCII')
			self.rename_btn.config(command = self.format_ascii)

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

	def load_vamas_ascii(self):
		descfilename = "/Users/pakpoomb/Documents/Caltech/Lewis Group/XPS/Nb/Nb.TXT"
		self.descpath = ntpath.dirname(descfilename)
		print(self.descpath)
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

		return

	def __init__(self, root):
		tk.Frame.__init__(self,root)
		self.grid()
		button_opt = {'padx': 5, 'pady': 5}
		#tk.Button(self, text='Open description file', command=self.askopenfile).pack(**button_opt)
		tk.Button(self, text='Open description file', command=self.load_vamas_ascii).grid(row=1, column=1, columnspan=2)
		
		# define options for opening a file
		self.file_opt = options = {}
		options['defaultextension'] = '.txt'
		options['filetypes'] = [('all files', '.*'), ('text files', '.txt')]
		options['parent'] = root
		options['title'] = 'Choose the main file'

def center(toplevel):
	toplevel.update_idletasks()
	w = toplevel.winfo_screenwidth()
	h = toplevel.winfo_screenheight()
	size = (w/5, h/3)
	#size = tuple(int(_) for _ in toplevel.geometry().split('+')[0].split('x'))
	x = w/2 - size[0]/2
	y = h/2 - size[1]/2
	toplevel.geometry("%dx%d+%d+%d" % (size + (x, y)))

if __name__=='__main__':
	root = tk.Tk()
	FormatCasaAscii(root)
	center(root)
	root.title("FormatCasaAscii")
	root.lift()
	os.system('''/usr/bin/osascript -e 'tell app "Finder" to set frontmost of process "Python" to true' ''')
	root.mainloop()
