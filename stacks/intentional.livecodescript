script "intentional.lc"
getprop dep_StackNames
   return "lib_Fedwiki,lib_Intentionalcommunity,lib_Map,lib_PageArray,lib_Transport,model_PageArray"
end dep_StackNames

on index
   put fedwiki_GetDroppedUrl() into droppedURL
   put urldecode (droppedURL) into droppedURL
   _SetCountryAndProvince droppedURL, someCountry, someState, someCity
   --
   switch
      case droppedURL begins with "https://www.ic.org/directory/listings/?country="
      case droppedURL begins with "https://www.ic.org/directory/listings/?"
         put ic_FetchCountryData (someCountry, someState) into icListData
         --
         put someCountry into pageTitle
         if someState is not empty then put "," && someState after pageTitle
         put ic_PageFromListData (icListData, pageTitle) into pageArray
         --
         break
      case matchText (droppedURL, "https://www.ic.org/directory/(.+)/", typeOrSlug)
         put _ConstructTypeOrSlugPageArray (typeOrSlug) into pageArray
         break
      default
         put pageArray_Construct ("Error", "Not a www.ic.org listing!") into pageArray
   end switch
   --
   fedwiki_ReturnPageArray pageArray
end index

on importCommunity
   put transport_GetFormValue ("icSlug") into icSlug
   -- put "serene-light-gardens" into icSlug
   --
   put ic_FetchCommunityData (icSlug) into communityData
   put ic_PageFromCommunityData (communityData) into pageArray
   --
   fedwiki_ReturnPageArray pageArray
end importCommunity

on importCountry
   put transport_GetFormValue ("country") into someCountry
   --
   put ic_PageFromCountry (someCountry) into pageArray
   fedwiki_ReturnPageArray pageArray
end importCountry

on createContact
   put fedwiki_GetDroppedArray() into postArray
   put postArray ["contactName"] into contactName
   put postArray ["contactPhone"] into contactPhone
   --
   put contactName into pageTitle
   put pageArray_Construct (pageTitle, contactPhone) into pageArray
   --
   fedwiki_ReturnPageArray pageArray
end createContact

private command _SetCountryAndProvince droppedURL, @someCountry, @someState, @someCity
   -- country=Austria
   set the itemdelimiter to "?"
   put item -1 of droppedURL into dirParamArray
   split dirParamArray with "&" and "="
   --
   put dirParamArray ["country"] into someCountry
   put dirParamArray ["state"] into someState
   if someState is empty then
      put dirParamArray ["province"] into someState
   end if
   put dirParamArray ["city"] into someCity
end _SetCountryAndProvince

private function _ConstructTypeOrSlugPageArray typeOrSlug
   switch typeOrSlug
      /*
      case "Christian Communities"
      case "jewish-communities"
         put ic_FetchCommunityTypeData ("spiritual", "&spiritual=Jewish") into communityTypeData
         put ic_PageFromCommunityTypeData (communityTypeData, "Coop") into pageArray
         break
         */
      case "Cohousing"
      case "cohousing-communities"
         put ic_FetchCommunityTypeData ("Cohousing") into communityTypeData
         put ic_PageFromCommunityTypeData (communityTypeData, typeOrSlug) into pageArray
         break
         break
      case "Co-ops"
      case "Student Co-ops"
         put ic_FetchCommunityDescriptionData ("coop") into communityTypeData
         put ic_PageFromCommunityTypeData (communityTypeData, typeOrSlug) into pageArray
         break
      case "Ecovillages"
         put ic_FetchCommunityTypeData ("ecovillage") into communityTypeData
         put ic_PageFromCommunityTypeData (communityTypeData, typeOrSlug) into pageArray
         break
      case "Communes"
         put ic_FetchCommunityTypeData ("commune") into communityTypeData
         put ic_PageFromCommunityTypeData (communityTypeData, typeOrSlug) into pageArray
         break
      default
         -- https://www.ic.org/directory/gro-rainbow-community/
         put ic_FetchCommunityData (typeOrSlug) into communityData
         put ic_PageFromCommunityData (communityData) into pageArray
   end switch
   return pageArray
end _ConstructTypeOrSlugPageArray
