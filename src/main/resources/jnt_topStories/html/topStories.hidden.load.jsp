<%@ page language="java" contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="ui" uri="http://www.jahia.org/tags/uiComponentsLib" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="query" uri="http://www.jahia.org/tags/queryLib" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="s" uri="http://www.jahia.org/tags/search" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<%@ page import="java.util.Calendar" %>

<c:set var="pageView"><%= ((String) request.getParameter("pageView"))%>
</c:set>

<c:set var="topLevel" value="${currentNode.properties['j:level'].string}"/>
<c:if test="${jcr:isNodeType(currentNode, 'jdmix:topViews')}">
    <c:set var="view" value="${currentNode.properties['view'].string}"/>
    <c:set target="${moduleMap}" property="subNodesView" value="${view}"/>
</c:if>
<jsp:useBean id="now" class="java.util.Date"/>
<fmt:formatDate value="${now}" pattern="yyyy-MM-dd" var="today"/>

<c:if test="${renderContext.editMode}"><h4><fmt:message key="label.topStoriesArea"/></h4>

    <p><fmt:message key="label.componentDescription"/></p>
</c:if>

<c:choose>
    <c:when test="${view == 'newsroom'}">

        <jcr:sql var="topStories"
                 sql="select * from [jmix:topStory] as story where isdescendantnode(story, ['${renderContext.site.path}'])
         and story.[j:level]='${topLevel}' and (story.[j:endDate] is null or story.[j:endDate] > CAST('+${today}T00:00:00.000' as date)) order by story.[date] desc"
                 limit="${currentNode.properties['j:limit'].long}"/>

            <c:forEach items="${topStories.nodes}" var="topStory" varStatus="item">
                    <template:module view="hidden.newsroom${topLevel}" path="${topStory.path}">
                        <%-- pass count to subnode view --%>
                        <template:param name="nodePosition" value="${item.count}"/>
                        <%-- pass chosen levelto subnode view --%>
                        <template:param name="topLevel" value="${topLevel}"/>
                        <template:param name="last" value="${item.last}"/>
                    </template:module>

            </c:forEach>
        <c:if test="${jcr:isNodeType(currentNode, 'jdmix:internalLink')}">
            <c:set var="linkNode" value="${currentNode.properties.internalLink.node}"/>
            <c:set var="linkTitle" value="${currentNode.properties.linkTitle.string}"/>
            <c:if test="${empty linkTitle}">
                <c:set var="linkTitle" value="${linkNode.displayableName}"/>
            </c:if>
            <c:if test="${not empty linkNode}">
                <c:set var="pageUrl">
                    ${linkNode.url}?pageView=<c:choose><c:when test="${topLevel == 'first'}">top</c:when>
                    <c:when test="${topLevel == 'second'}">featured</c:when>
                    <c:otherwise>all</c:otherwise>
                </c:choose>
                </c:set>

                <ul class="pager">

                    <c:url var="moreStories" value=""/>
                    <li class="next"><a href="${pageUrl}">${linkTitle} <i
                            class="fa fa-angle-right"></i></a></li>
                </ul>
            </c:if>
        </c:if>
    </c:when>
    <c:when test="${pageView == 'top'}">
        <jcr:sql var="topStories"
                 sql="select * from [jmix:topStory] as story where isdescendantnode(story, ['${renderContext.site.path}'])
         and story.[j:level]='first' and (story.[j:endDate] is null or story.[j:endDate] > CAST('+${today}T00:00:00.000' as date)) order by story.[date] desc"/>

        <c:forEach items="${topStories.nodes}" var="topStory" varStatus="item">
            <template:module view="default" path="${topStory.path}">
                <template:param name="last" value="${item.last}"/>
            </template:module>
        </c:forEach>

    </c:when>
    <c:when test="${pageView == 'featured'}">
        <jcr:sql var="topStories"
                 sql="select * from [jmix:topStory] as story where isdescendantnode(story, ['${renderContext.site.path}'])
         and story.[j:level]='second' and (story.[j:endDate] is null or story.[j:endDate] > CAST('+${today}T00:00:00.000' as date)) order by story.[date] desc"/>

        <c:forEach items="${topStories.nodes}" var="topStory" varStatus="item">
            <template:module view="default" path="${topStory.path}">
                <template:param name="last" value="${item.last}"/>
            </template:module>
        </c:forEach>

    </c:when>
    <c:when test="${pageView == 'all'}">
        <jcr:sql var="topStories"
                 sql="select * from [jmix:topStory] as story where isdescendantnode(story, ['${renderContext.site.path}']) order by story.[date] desc"/>

        <c:forEach items="${topStories.nodes}" var="topStory" varStatus="item">
            <template:module view="default" path="${topStory.path}">
                <template:param name="last" value="${item.last}"/>
            </template:module>
        </c:forEach>

    </c:when>
    <c:otherwise>

<c:if test="${currentNode.properties['j:limit'].long gt 0}">

    <query:definition var="listQuery"
                      statement="select * from [jmix:topStory] as story where isdescendantnode(story, ['${renderContext.site.path}'])
         and story.[j:level]='${topLevel}' and (story.[j:endDate] is null or story.[j:endDate] > CAST('+${today}T00:00:00.000' as date)) order by story.[date] desc"
                      limit="${currentNode.properties['j:limit'].long}"/>

    <c:set target="${moduleMap}" property="editable" value="false" />
    <c:set target="${moduleMap}" property="listQuery" value="${listQuery}" />
    </c:if>
    </c:otherwise>
</c:choose>
