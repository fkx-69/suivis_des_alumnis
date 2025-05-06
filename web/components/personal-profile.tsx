import React from "react";
import {
  MDBCol,
  MDBRow,
  MDBCard,
  MDBCardText,
  MDBCardBody,
  MDBCardImage,
  MDBTypography,
  MDBIcon,
} from "mdb-react-ui-kit";

import { SquarePen, SquarePenIcon } from "lucide-react";

// Gradient identique à la maquette
const gradientStyle = {
  background: "linear-gradient(to bottom right, #FFD259, #FF8E53)",
};

export default function PersonalProfile() {
  return (
    <MDBCard className="flex flex-wrap relative max-w-max font-sans rounded-lg overflow-hidden">
      <SquarePenIcon
        className="absolute top-3 right-3 text-white/80 text-lg cursor-pointer z-10"
        size="20"
        color="back"
      />
      {/* ─────────── Colonne de gauche ─────────── */}
      <MDBCol
        className="d-flex flex-column align-items-center text-center text-white"
        style={{
          ...gradientStyle,
          borderTopLeftRadius: ".5rem",
          borderBottomLeftRadius: ".5rem",
          width: "120px", // taille fixe pour col gauche
          padding: "1.5rem",
        }}
      >
        <MDBCardImage
          src="/profile/avatar.jpg"
          alt="Avatar"
          className="rounded-circle mb-3"
          style={{ width: "80px", height: "80px", objectFit: "cover" }}
          fluid
          onError={(e) => {
            const img = e.target as HTMLImageElement;
            img.src = "/profile/default-avatar.png";
            img.onerror = null;
          }}
        />

        <MDBTypography tag="h5" className="mb-1" style={{ fontWeight: "600" }}>
          Marie Horwitz
        </MDBTypography>
        <MDBCardText className="small mb-4" style={{ opacity: 0.9 }}>
          Web Designer
        </MDBCardText>

        <a href="#!" className="text-white">
          <MDBIcon far icon="edit" size="lg" />
        </a>
      </MDBCol>

      {/* ─────────── Colonne de droite ─────────── */}
      <MDBCol>
        <MDBCardBody style={{ padding: "1.5rem" }}>
          {/* Information */}
          <MDBTypography tag="h6" style={{ fontWeight: "500" }}>
            Information
          </MDBTypography>
          <hr style={{ margin: "0.5rem 0 1rem" }} />

          <MDBRow className="mb-3">
            <MDBCol size="6">
              <MDBTypography tag="h6" className="small text-muted">
                Email
              </MDBTypography>
              {/* on force le retour à la ligne si besoin */}
              <MDBCardText style={{ wordBreak: "break-word" }}>
                info@example.
                <br />
                com
              </MDBCardText>
            </MDBCol>
            <MDBCol size="6">
              <MDBTypography tag="h6" className="small text-muted">
                Phone
              </MDBTypography>
              <MDBCardText>123 456 789</MDBCardText>
            </MDBCol>
          </MDBRow>

          {/* Projets */}
          <MDBTypography
            tag="h6"
            className="mt-2"
            style={{ fontWeight: "500" }}
          >
            Projects
          </MDBTypography>
          <hr style={{ margin: "0.5rem 0 1rem" }} />

          <MDBRow className="mb-3">
            <MDBCol size="6">
              <MDBTypography tag="h6" className="small text-muted">
                Recent
              </MDBTypography>
              <MDBCardText>Lorem ipsum</MDBCardText>
            </MDBCol>
            <MDBCol size="6">
              <MDBTypography tag="h6" className="small text-muted">
                Most Viewed
              </MDBTypography>
              <MDBCardText>Dolor sit amet</MDBCardText>
            </MDBCol>
          </MDBRow>

          {/* Réseaux sociaux */}
          <div className="d-flex">
            <a href="#!" className="me-3">
              <MDBIcon
                fab
                icon="facebook-f"
                size="lg"
                style={{ color: "#3b5998" }}
              />
            </a>
            <a href="#!" className="me-3">
              <MDBIcon
                fab
                icon="twitter"
                size="lg"
                style={{ color: "#1da1f2" }}
              />
            </a>
            <a href="#!">
              <MDBIcon
                fab
                icon="instagram"
                size="lg"
                style={{ color: "#c32aa3" }}
              />
            </a>
          </div>
        </MDBCardBody>
      </MDBCol>
    </MDBCard>
  );
}
