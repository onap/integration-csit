package org.onap.so.svnfm.simulator.model;

import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@ConfigurationProperties(prefix = "vnfds")
@Component
public class Vnfds {

    private List<Vnfd> vnfdList;

    public static class Vnfd {

        private String vnfdId;
        private List<Vnfc> vnfclist;


        public String getVnfdId() {
            return vnfdId;
        }

        public void setVnfdId(final String vnfdId) {
            this.vnfdId = vnfdId;
        }

        public List<Vnfc> getVnfcList() {
            return vnfclist;
        }

        public void setVnfcList(final List<Vnfc> vnfclist) {
            this.vnfclist = vnfclist;
        }

        @Override
        public String toString() {
            final StringBuilder sb = new StringBuilder();
            sb.append("class Vnfd {\n");
            sb.append("    vnfdId: ").append(vnfdId).append("\n");
            sb.append("    vnfclist: ").append(vnfclist).append("\n");
            sb.append("}");
            return sb.toString();
        }

    }


    public static class Vnfc {

        private String vnfcId;
        private String type;
        private String vduId;
        private String resourceTemplateId;
        private String grantResourceId;

        public String getVnfcId() {
            return vnfcId;
        }

        public void setVnfcId(final String vnfcId) {
            this.vnfcId = vnfcId;
        }

        public String getVduId() {
            return vduId;
        }

        public void setVduId(final String vduId) {
            this.vduId = vduId;
        }

        public String getType() {
            return type;
        }

        public void setType(final String type) {
            this.type = type;
        }

        public String getResourceTemplateId() {
            return resourceTemplateId;
        }

        public void setResourceTemplateId(final String resourceTemplateId) {
            this.resourceTemplateId = resourceTemplateId;
        }

        public String getGrantResourceId() {
            return grantResourceId;
        }

        public void setGrantResourceId(final String grantResourceId) {
            this.grantResourceId = grantResourceId;
        }

        @Override
        public String toString() {
            final StringBuilder sb = new StringBuilder();
            sb.append("class Vnfc {\n");
            sb.append("    vnfcId: ").append(vnfcId).append("\n");
            sb.append("    type: ").append(type).append("\n");
            sb.append("    vduId: ").append(vduId).append("\n");
            sb.append("    resourceTemplateId: ").append(resourceTemplateId).append("\n");
            sb.append("    grantResourceId: ").append(grantResourceId).append("\n");
            sb.append("}");
            return sb.toString();
        }

    }

    public List<Vnfd> getVnfdList() {
        return vnfdList;
    }


    public void setVnfdList(final List<Vnfd> vnfdList) {
        this.vnfdList = vnfdList;
    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder();
        sb.append("class Vnfds {\n");
        sb.append("    vnfdList: ").append(vnfdList).append("\n");
        sb.append("}");
        return sb.toString();
    }



}
