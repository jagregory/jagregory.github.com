---
layout: post
title: getfilename NAnt task
tags:
- .Net
- Code
- NAnt
status: publish
type: post
published: true
meta: {}
---
As part of my current quest to fully automate our build, I found my self needing the ability to copy a database backup from our remote server. The backup is in a folder along with several other backups, with a filename based on the date. I didn't fancy trying to programmatically guess the filename, so I wrote an NAnt task to grab the newest file in a directory. Thanks to [Richard Case](http://blogs.geekdojo.net/rcase) for his overview of how to [create a custom NAnt task](http://blogs.geekdojo.net/rcase/archive/2005/01/06/5971.aspx).

The `getfilename` task simply gets the filename of a file in a directory, then pushes the name into the specified property. The filename to find can be based on the creation date, last modified date etc...

<!-- more -->

The attributes are as follows:

<table class="format-table">
	<thead>
		<tr>
			<th>Attribute</th>
			<th>Description</th>
			<th>Required</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>in</td>
			<td>The directory to search</td>
			<td>Yes</td>
		</tr>
		<tr class="alt">
			<td>property</td>
			<td>The property to push the filename into.</td>
			<td>Yes</td>
		</tr>
		<tr>
			<td>searchPattern</td>
			<td>Wildcard search pattern for finding the file.</td>
			<td>No</td>
		</tr>
		<tr class="alt">
			<td>of</td>
			<td>
				The file to get the filename of.<br /><br />
				<strong>NewestFile</strong> - The most recently created file<br />
				<strong>OldestFile</strong> - The oldest file in the directory<br />
				<strong>FirstModifiedFile</strong> - The file with the oldest last modified date<br />
				<strong>LastModifiedFile</strong> - The most recently modified file<br />
				<strong>FirstFile</strong> - The first file in the directory, using default sorting<br />
				<strong>LastFile</strong> - The last file in the directory, using default sorting<br />
			</td>
			<td>No - Defaults to NewestFile</td>
		</tr>
	</tbody>
</table>

An example usage is:

``` xml
<?xml version="1.0"?>
<project name="Example" default="run">
  <target name="run">
    <getfilename of="NewestFile" in="C:\path\to\backups" searchPattern="*.bak" property="filename" />
    <echo message="Filename: ${filename}" />
  </target>
</project>
```

Foreseeable usage situations revolve around anything where you'd need to get the last modified, or newest file in a directory; backups, database scripts etc...

## Downloads

> Note from Future James: This is long gone.
