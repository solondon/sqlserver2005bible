<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format">
	<xsl:template match="/">
		<html>
			<body>
				<b> Cape Hatteras Adventures </b>
				<br/>
      Event Schedule
      <hr/>
				<xsl:apply-templates select="Tours"/>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="Tours">
		<xsl:for-each select="Tour">
			<xsl:sort select="Name"/>
			<b>
				<xsl:value-of select="@Name"/>
			</b>
			<br/>
			<table border="1">
				<xsl:for-each select="Event">
					<xsl:sort select="DateBegin "/>
					<tr>
						<td>
							<xsl:value-of select="@Code"/>
						</td>
						<td>
							<xsl:value-of select="@DateBegin"/>
						</td>
					</tr>
				</xsl:for-each>
			</table>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
