<!--
    © 2019 and later: Unicode, Inc. and others.
    License & terms of use: http://www.unicode.org/copyright.html
    This is the XSLT for the API Report, Markdown version
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:param name="leftVer" />
  <xsl:param name="rightVer" />
  <xsl:param name="dateTime" />
  <xsl:param name="rightMilestone" />
  <xsl:param name="leftMilestone" />
  <xsl:param name="notFound" />
  <!-- <xsl:param name="ourYear" /> -->
  <xsl:output method="text" indent="no" omit-xml-declaration="yes" />
  <xsl:template match="/">
  <!-- the generated file has a copyright of 2019 and following -->
<![CDATA[<!--]]>
 Copyright © 2019 and later: Unicode, Inc. and others.
 License &amp; terms of use: http://www.unicode.org/copyright.html
<![CDATA[-->]]>

# ICU4C API Comparison: <xsl:value-of select="$leftVer"/><xsl:value-of select="$leftMilestone" /> with <xsl:value-of select="$rightVer" /><xsl:value-of select="$rightMilestone" />

> _Note_ Markdown format of this document is new for ICU 65.

- [Removed from <xsl:value-of select="$leftVer"/>](#removed)
- [Deprecated or Obsoleted in <xsl:value-of select="$rightVer" />](#deprecated)
- [Changed in  <xsl:value-of select="$rightVer" />](#changed)
- [Promoted to stable in <xsl:value-of select="$rightVer" />](#promoted)
- [Added in <xsl:value-of select="$rightVer" />](#added)
- [Other existing drafts in <xsl:value-of select="$rightVer" />](#other)
- [Signature Simplifications](#simplifications)

## Removed

Removed from <xsl:value-of select="$leftVer"/>
<xsl:call-template name="genTable">
    <xsl:with-param name="nodes" select="/list/func[@rightStatus=$notFound]"/>
</xsl:call-template>

## Deprecated

Deprecated or Obsoleted in <xsl:value-of select="$rightVer" />

<xsl:call-template name="genTable">
    <xsl:with-param name="nodes" select="/list/func[(@rightStatus='Deprecated' and @leftStatus!='Deprecated') or (@rightStatus='Obsolete' and @leftStatus!='Obsolete')]"/>
</xsl:call-template>

## Changed

Changed in  <xsl:value-of select="$rightVer" /> (old, new)

<xsl:call-template name="genTable">
    <xsl:with-param name="nodes" select="/list/func[(@leftStatus != $notFound) and (@rightStatus != $notFound) and ( (@leftStatus != @rightStatus) or (@leftVersion != @rightVersion) ) and not ( (@leftStatus = 'Draft') and (@rightStatus = 'Stable') and (@rightVersion = $rightVer) )]"/>
</xsl:call-template>

## Promoted

Promoted to stable in <xsl:value-of select="$rightVer" />

<xsl:call-template name="genTable">
    <xsl:with-param name="nodes" select="/list/func[@leftStatus != 'Stable' and  @rightStatus = 'Stable']"/>
</xsl:call-template>

## Added

Added in <xsl:value-of select="$rightVer" />

<xsl:call-template name="genTable">
    <xsl:with-param name="nodes" select="/list/func[@leftStatus=$notFound]"/>
</xsl:call-template>

## Other

Other existing drafts in <xsl:value-of select="$rightVer" />

<xsl:call-template name="infoTable"> <!--  note: note genTable -->
    <xsl:with-param name="nodes" select="/list/func[@rightStatus = 'Draft' and @rightVersion != $rightVer]"/>
</xsl:call-template>

## Simplifications

This section shows cases where the signature was "simplified" for the sake of comparison. The simplified form is in bold, followed by
    all possible variations in "original" form.
<xsl:for-each select="/list/simplifications/simplification">
- **`<xsl:value-of select="base" />`**<xsl:for-each select="change">
  - `<xsl:value-of select="text()" />`</xsl:for-each>
</xsl:for-each>

## Colophon

Contents generated by StableAPI tool on <xsl:value-of select="$dateTime" />

Copyright © 2019 and later: Unicode, Inc. and others.
License &amp; terms of use: http://www.unicode.org/copyright.html
  </xsl:template>

  <!-- almost all sutables are generated by this -->
  <xsl:template name="genTable"><xsl:param name="nodes" />
  
| <xsl:value-of select="'File'" /> | <xsl:value-of select="'API'" /> | <xsl:value-of select="$leftVer" /> | <xsl:value-of select="$rightVer" /> |
|---|---|---|---|<xsl:for-each select="$nodes"><xsl:sort select="@file" />
<!--
            <xsl:comment>
              @prototype: <xsl:value-of select="@prototype" />
              @leftStatus: <xsl:value-of select="@leftStatus" />
              @leftVersion: <xsl:value-of select="@leftVersion" />
              @rightStatus: <xsl:value-of select="@rightStatus" />
              @rightVersion: <xsl:value-of select="@rightVersion" />
            </xsl:comment>
-->| <xsl:value-of select="@file" /> | <xsl:value-of disable-output-escaping="yes" select="@prototype" /> | <!-- <xsl:if 
    test ="@leftStatus = 'Stable'">
                                <xsl:value-of select="'stabchange'" />
                        </xsl:if>
                    </xsl:attribute>
                   	<xsl:if  test = "@leftStatus = 'Draft' and @rightStatus = 'Stable' and @leftVersion = @rightVersion">
	                    <xsl:attribute name="colspan">2</xsl:attribute>
	                    <xsl:attribute name="align">center</xsl:attribute>
                   	</xsl:if> --> <xsl:value-of select="@leftStatus" /> <xsl:if 
                        test = "@leftStatus = 'Draft' and @rightStatus = 'Stable' and @leftVersion = @rightVersion">&#x2192;Stable</xsl:if><xsl:if
                         test="@leftVersion != '' and @leftVersion != '.'"> <xsl:value-of select="@leftVersion" />  </xsl:if><xsl:if
                          test="@leftStatus = '' and @leftVersion = ''"> _untagged _ </xsl:if><xsl:if 
                           test = "@leftStatus != 'Draft' or @rightStatus != 'Stable' or @leftVersion != @rightVersion"> | <xsl:value-of select="@rightStatus" /> <!--
                        <xsl:attribute name="class">
                            <xsl:if test ="@leftVersion != @rightVersion and @leftVersion != '' and @rightVersion != '' and @rightVersion != '.'">
                                <xsl:value-of select="'verchange'" />
                            </xsl:if>
                        </xsl:attribute>--><xsl:if test="@rightVersion != '.'"><xsl:value-of select="@rightVersion" /></xsl:if><xsl:if 
                        test ="@leftVersion != @rightVersion and @leftVersion != '' and @rightVersion != '' and @rightStatus = 'Stable' and not ( (@leftStatus = 'Draft') and (@rightStatus = 'Stable') and (@rightVersion = $rightVer) )">
                            *(changed)*
                        </xsl:if>
                        <xsl:if test ="@rightStatus = 'Draft' and @rightVersion != $rightVer">
                            *(should be <xsl:value-of select="$rightVer"/>)*
                        </xsl:if>
                        <xsl:if test="@leftStatus = $notFound and @rightVersion = '' and @rightStatus != 'Internal' and @rightStatus != 'Deprecated'">
                        	*(untagged)*
                        </xsl:if>
           </xsl:if><xsl:if  test = "@rightStatus = 'Stable' and @rightVersion = $rightVer">| *(Born Stable)* |</xsl:if></xsl:for-each>
  </xsl:template>

    <xsl:template name="infoTable">
    <xsl:param name="nodes" />

| <xsl:value-of select="'File'" /> | <xsl:value-of select="'API'" /> | <xsl:value-of select="$leftVer" /> | <xsl:value-of select="$rightVer" /> |
|---|---|---|---|<xsl:for-each select="$nodes"><xsl:sort select="@file" 
    />
| <xsl:value-of select="@file" /> |  <xsl:value-of disable-output-escaping="yes" select="@prototype" /> | <xsl:if 
 test = "@leftStatus = @rightStatus and @leftVersion = @rightVersion"> <xsl:value-of select="@leftStatus" /> <xsl:value-of select="@leftVersion" /> | <xsl:if test = "@leftStatus != @rightStatus or @leftVersion != @rightVersion"> <xsl:value-of 
 select="@rightStatus" /> <xsl:if 
 test = "@rightVersion != '.'"><xsl:value-of select="@rightVersion" /></xsl:if></xsl:if></xsl:if></xsl:for-each>
  </xsl:template>


    <xsl:template name="pureVirtualTable">
    <xsl:param name="nodes" />
    <!--
    <THEAD>
        <tr>
            <th> <xsl:value-of select="'File'" /> </th>
            <th> <xsl:value-of select="'API'" /> </th>
            <th> <xsl:value-of select="$leftVer" /> </th>
            <th> <xsl:value-of select="$rightVer" /> </th>
        </tr>
    </THEAD>
    -->

        <xsl:for-each select="$nodes">
            <xsl:sort select="@file" />

            <tr>
                <xsl:attribute name="class">
                    <xsl:value-of select="'row'"/>
                    <xsl:value-of select="(position() mod 2)"/>
                    <!--
                    <xsl:choose>
                        <xsl:when test="(position() mod 2) = 0"><xsl:value-of select="row0" /></xsl:when>
                        <xsl:otherwise><xsl:value-of select="row1" /></xsl:otherwise>
                    </xsl:choose>
                    -->
                </xsl:attribute>
                <td class='file'> <xsl:value-of select="@file" /> </td>
                <td class='proto'> <xsl:value-of disable-output-escaping="yes" select="@prototype" /> </td>
                <td>
                    <xsl:attribute name="class">
                        <xsl:if test ="@leftStatus = 'Stable'">
                                <xsl:value-of select="'stabchange'" />
                        </xsl:if>
                    </xsl:attribute>

                   	<xsl:if  test = "@leftStatus = @rightStatus and @leftVersion = @rightVersion">
	                    <xsl:attribute name="colspan">2</xsl:attribute>
	                    <xsl:attribute name="align">center</xsl:attribute>
                   	</xsl:if>

                    <xsl:value-of select="@leftStatus" />
                    <br/> <xsl:value-of select="@leftVersion" />
                </td>
                <xsl:if test = "@leftStatus != @rightStatus or @leftVersion != @rightVersion">
                <td> <xsl:value-of select="@rightStatus" />
                    <br/>
                    <span>
                        <xsl:attribute name="class">
                            <xsl:if test ="@leftVersion != @rightVersion and @leftVersion != '' and @rightVersion != ''">
                                <xsl:value-of select="'verchange'" />
                            </xsl:if>
                        </xsl:attribute>
                        <span>
                            <xsl:value-of select="@rightVersion" />
                        </span>
                   <!--
                        <xsl:if test ="@leftVersion != @rightVersion and @leftVersion != '' and @rightVersion != '' and @rightStatus = 'Stable'">
                            <br/><b title='A stable API changed version.' class='bigwarn'>(changed)</b>
                        </xsl:if>
                        <xsl:if test ="@rightStatus = 'Draft' and @rightVersion != $rightVer">
                            <br/><b title='A draft API has the wrong version.' class='bigwarn'>(should be <xsl:value-of select="$rightVer"/>)</b>
                        </xsl:if>
                        <xsl:if test="@leftStatus = $notFound and @rightVersion = ''">
                        	<br/><b title='A new API was introduced that was not tagged.' class='bigwarn'>(untagged)</b>
                        </xsl:if>
                     -->
                    </span>
                </td>
                </xsl:if>
            </tr>
        </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
