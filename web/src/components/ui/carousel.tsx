"use client";

import { ChevronLeft, ChevronRight } from "lucide-react";
import React, { useRef, useEffect, useState, useCallback } from "react";

interface CarouselProps {
  children: React.ReactNode;
}

export function Carousel({ children }: CarouselProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [cardElements, setCardElements] = useState<HTMLElement[]>([]);
  const [currentActiveIndex, setCurrentActiveIndex] = useState(0);

  useEffect(() => {
    if (containerRef.current) {
      setCardElements(
        Array.from(containerRef.current.children) as HTMLElement[]
      );
    }
  }, [children]);

  const updateCardStyles = useCallback(() => {
    if (!containerRef.current) return;
    const containerCenter =
      containerRef.current.scrollLeft + containerRef.current.offsetWidth / 2;
    const influenceZone = containerRef.current.offsetWidth / 1.5;

    cardElements.forEach((card) => {
      const cardCenter = card.offsetLeft + card.offsetWidth / 2;
      const distance = Math.abs(containerCenter - cardCenter);

      const scaleValue = Math.max(0.9, 1 - (distance / influenceZone) * 0.1);
      const opacityValue = Math.max(0.7, 1 - (distance / influenceZone) * 0.3);

      card.style.transform = `scale(${scaleValue})`;
      card.style.opacity = `${opacityValue}`;
    });
  }, [cardElements]);

  const updateCurrentIndex = useCallback(() => {
    if (!containerRef.current) return 0;
    const containerCenter =
      containerRef.current.scrollLeft + containerRef.current.offsetWidth / 2;
    let closestIndex = 0;
    let minDistance = Infinity;

    cardElements.forEach((card, index) => {
      const cardCenter = card.offsetLeft + card.offsetWidth / 2;
      const distance = Math.abs(containerCenter - cardCenter);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = index;
      }
    });
    setCurrentActiveIndex(closestIndex);
    return closestIndex;
  }, [cardElements]);

  const scrollToCard = (index: number) => {
    if (index < 0) index = 0;
    if (index >= cardElements.length) index = cardElements.length - 1;

    const card = cardElements[index];
    if (!card || !containerRef.current) return;

    const scrollLeft =
      card.offsetLeft -
      containerRef.current.offsetWidth / 2 +
      card.offsetWidth / 2;
    containerRef.current.scrollTo({
      left: scrollLeft,
      behavior: "smooth",
    });
    setCurrentActiveIndex(index);
  };

  const handlePrev = () => {
    const newIndex = updateCurrentIndex();
    scrollToCard(newIndex - 1);
  };

  const handleNext = () => {
    const newIndex = updateCurrentIndex();
    scrollToCard(newIndex + 1);
  };

  useEffect(() => {
    const container = containerRef.current;
    const handleScroll = () => {
      window.requestAnimationFrame(updateCardStyles);
    };

    if (container) {
      container.addEventListener("scroll", handleScroll);
    }

    // Initial load
    const timer1 = setTimeout(() => {
      scrollToCard(0);
      const timer2 = setTimeout(
        () => window.requestAnimationFrame(updateCardStyles),
        100
      );
      return () => clearTimeout(timer2);
    }, 100);

    return () => {
      if (container) {
        container.removeEventListener("scroll", handleScroll);
      }
      clearTimeout(timer1);
    };
  }, [cardElements, updateCardStyles]);

  return (
    <div className="relative">
      <div
        ref={containerRef}
        className="flex overflow-x-auto no-scrollbar scroll-smooth snap-x snap-mandatory gap-4 md:gap-6 py-8 px-[33%]"
      >
        {children}
      </div>

      <button
        onClick={handlePrev}
        className="nav-button absolute top-1/2 left-4 -translate-y-1/2 bg-base-300/80 backdrop-blur-sm rounded-full p-2 text-base-content transition-transform duration-300 z-10 hover:scale-110 hover:bg-base-content/15"
      >
        <ChevronLeft />
      </button>
      <button
        onClick={handleNext}
        className="nav-button absolute top-1/2 right-4 -translate-y-1/2 bg-base-300/80 backdrop-blur-sm rounded-full p-2 text-base-content transition-transform duration-300 z-10 hover:scale-110 hover:bg-base-content/15"
      >
        <ChevronRight />
      </button>
    </div>
  );
}
